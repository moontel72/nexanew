// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revenue_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevenueReport {

 String get id; String get reportNumber; String get reportName; ReportType get type; DateTime get periodStart; DateTime get periodEnd; DateTime get generatedAt; String get generatedByAdminId; String get generatedByAdminName; ReportStatus get status;// Revenue summary
 double get totalRevenue; double get collectedRevenue; double get pendingRevenue; double get overdueRevenue; double get refundedRevenue; double get creditNoteAmount;// Invoice statistics
 int get totalInvoices; int get paidInvoices; int get pendingInvoices; int get overdueInvoices; int get draftInvoices; int get cancelledInvoices; int get refundedInvoices;// Payment statistics
 int get totalPayments; double get averagePaymentAmount; double get medianPaymentAmount; int get averagePaymentDays;// Company statistics
 int get activeCompanies; int get companiesWithOverdue; int get companiesWithCredit;// Breakdowns
 Map<String, double>? get revenueByPlan; Map<String, double>? get revenueByCompanyType; Map<String, double>? get revenueByPaymentMethod; Map<String, int>? get invoiceCountByStatus; Map<String, double>? get revenueByMonth;// Trend data
 List<MonthlyRevenueTrend>? get monthlyTrends; List<CompanyRevenueRanking>? get topCompaniesByRevenue; List<PlanRevenueRanking>? get topPlansByRevenue;// Report details
 String? get notes; Map<String, dynamic>? get reportData; Map<String, dynamic>? get metadata; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RevenueReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueReportCopyWith<RevenueReport> get copyWith => _$RevenueReportCopyWithImpl<RevenueReport>(this as RevenueReport, _$identity);

  /// Serializes this RevenueReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reportNumber, reportNumber) || other.reportNumber == reportNumber)&&(identical(other.reportName, reportName) || other.reportName == reportName)&&(identical(other.type, type) || other.type == type)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.generatedByAdminId, generatedByAdminId) || other.generatedByAdminId == generatedByAdminId)&&(identical(other.generatedByAdminName, generatedByAdminName) || other.generatedByAdminName == generatedByAdminName)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.refundedRevenue, refundedRevenue) || other.refundedRevenue == refundedRevenue)&&(identical(other.creditNoteAmount, creditNoteAmount) || other.creditNoteAmount == creditNoteAmount)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.draftInvoices, draftInvoices) || other.draftInvoices == draftInvoices)&&(identical(other.cancelledInvoices, cancelledInvoices) || other.cancelledInvoices == cancelledInvoices)&&(identical(other.refundedInvoices, refundedInvoices) || other.refundedInvoices == refundedInvoices)&&(identical(other.totalPayments, totalPayments) || other.totalPayments == totalPayments)&&(identical(other.averagePaymentAmount, averagePaymentAmount) || other.averagePaymentAmount == averagePaymentAmount)&&(identical(other.medianPaymentAmount, medianPaymentAmount) || other.medianPaymentAmount == medianPaymentAmount)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.activeCompanies, activeCompanies) || other.activeCompanies == activeCompanies)&&(identical(other.companiesWithOverdue, companiesWithOverdue) || other.companiesWithOverdue == companiesWithOverdue)&&(identical(other.companiesWithCredit, companiesWithCredit) || other.companiesWithCredit == companiesWithCredit)&&const DeepCollectionEquality().equals(other.revenueByPlan, revenueByPlan)&&const DeepCollectionEquality().equals(other.revenueByCompanyType, revenueByCompanyType)&&const DeepCollectionEquality().equals(other.revenueByPaymentMethod, revenueByPaymentMethod)&&const DeepCollectionEquality().equals(other.invoiceCountByStatus, invoiceCountByStatus)&&const DeepCollectionEquality().equals(other.revenueByMonth, revenueByMonth)&&const DeepCollectionEquality().equals(other.monthlyTrends, monthlyTrends)&&const DeepCollectionEquality().equals(other.topCompaniesByRevenue, topCompaniesByRevenue)&&const DeepCollectionEquality().equals(other.topPlansByRevenue, topPlansByRevenue)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.reportData, reportData)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportNumber,reportName,type,periodStart,periodEnd,generatedAt,generatedByAdminId,generatedByAdminName,status,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,refundedRevenue,creditNoteAmount,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,draftInvoices,cancelledInvoices,refundedInvoices,totalPayments,averagePaymentAmount,medianPaymentAmount,averagePaymentDays,activeCompanies,companiesWithOverdue,companiesWithCredit,const DeepCollectionEquality().hash(revenueByPlan),const DeepCollectionEquality().hash(revenueByCompanyType),const DeepCollectionEquality().hash(revenueByPaymentMethod),const DeepCollectionEquality().hash(invoiceCountByStatus),const DeepCollectionEquality().hash(revenueByMonth),const DeepCollectionEquality().hash(monthlyTrends),const DeepCollectionEquality().hash(topCompaniesByRevenue),const DeepCollectionEquality().hash(topPlansByRevenue),notes,const DeepCollectionEquality().hash(reportData),const DeepCollectionEquality().hash(metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'RevenueReport(id: $id, reportNumber: $reportNumber, reportName: $reportName, type: $type, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, generatedByAdminId: $generatedByAdminId, generatedByAdminName: $generatedByAdminName, status: $status, totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, refundedRevenue: $refundedRevenue, creditNoteAmount: $creditNoteAmount, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, draftInvoices: $draftInvoices, cancelledInvoices: $cancelledInvoices, refundedInvoices: $refundedInvoices, totalPayments: $totalPayments, averagePaymentAmount: $averagePaymentAmount, medianPaymentAmount: $medianPaymentAmount, averagePaymentDays: $averagePaymentDays, activeCompanies: $activeCompanies, companiesWithOverdue: $companiesWithOverdue, companiesWithCredit: $companiesWithCredit, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, revenueByPaymentMethod: $revenueByPaymentMethod, invoiceCountByStatus: $invoiceCountByStatus, revenueByMonth: $revenueByMonth, monthlyTrends: $monthlyTrends, topCompaniesByRevenue: $topCompaniesByRevenue, topPlansByRevenue: $topPlansByRevenue, notes: $notes, reportData: $reportData, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RevenueReportCopyWith<$Res>  {
  factory $RevenueReportCopyWith(RevenueReport value, $Res Function(RevenueReport) _then) = _$RevenueReportCopyWithImpl;
@useResult
$Res call({
 String id, String reportNumber, String reportName, ReportType type, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, String generatedByAdminId, String generatedByAdminName, ReportStatus status, double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, double refundedRevenue, double creditNoteAmount, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, int draftInvoices, int cancelledInvoices, int refundedInvoices, int totalPayments, double averagePaymentAmount, double medianPaymentAmount, int averagePaymentDays, int activeCompanies, int companiesWithOverdue, int companiesWithCredit, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, Map<String, double>? revenueByPaymentMethod, Map<String, int>? invoiceCountByStatus, Map<String, double>? revenueByMonth, List<MonthlyRevenueTrend>? monthlyTrends, List<CompanyRevenueRanking>? topCompaniesByRevenue, List<PlanRevenueRanking>? topPlansByRevenue, String? notes, Map<String, dynamic>? reportData, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RevenueReportCopyWithImpl<$Res>
    implements $RevenueReportCopyWith<$Res> {
  _$RevenueReportCopyWithImpl(this._self, this._then);

  final RevenueReport _self;
  final $Res Function(RevenueReport) _then;

/// Create a copy of RevenueReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportNumber = null,Object? reportName = null,Object? type = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? generatedByAdminId = null,Object? generatedByAdminName = null,Object? status = null,Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? refundedRevenue = null,Object? creditNoteAmount = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? draftInvoices = null,Object? cancelledInvoices = null,Object? refundedInvoices = null,Object? totalPayments = null,Object? averagePaymentAmount = null,Object? medianPaymentAmount = null,Object? averagePaymentDays = null,Object? activeCompanies = null,Object? companiesWithOverdue = null,Object? companiesWithCredit = null,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? revenueByPaymentMethod = freezed,Object? invoiceCountByStatus = freezed,Object? revenueByMonth = freezed,Object? monthlyTrends = freezed,Object? topCompaniesByRevenue = freezed,Object? topPlansByRevenue = freezed,Object? notes = freezed,Object? reportData = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportNumber: null == reportNumber ? _self.reportNumber : reportNumber // ignore: cast_nullable_to_non_nullable
as String,reportName: null == reportName ? _self.reportName : reportName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReportType,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,generatedByAdminId: null == generatedByAdminId ? _self.generatedByAdminId : generatedByAdminId // ignore: cast_nullable_to_non_nullable
as String,generatedByAdminName: null == generatedByAdminName ? _self.generatedByAdminName : generatedByAdminName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,refundedRevenue: null == refundedRevenue ? _self.refundedRevenue : refundedRevenue // ignore: cast_nullable_to_non_nullable
as double,creditNoteAmount: null == creditNoteAmount ? _self.creditNoteAmount : creditNoteAmount // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,draftInvoices: null == draftInvoices ? _self.draftInvoices : draftInvoices // ignore: cast_nullable_to_non_nullable
as int,cancelledInvoices: null == cancelledInvoices ? _self.cancelledInvoices : cancelledInvoices // ignore: cast_nullable_to_non_nullable
as int,refundedInvoices: null == refundedInvoices ? _self.refundedInvoices : refundedInvoices // ignore: cast_nullable_to_non_nullable
as int,totalPayments: null == totalPayments ? _self.totalPayments : totalPayments // ignore: cast_nullable_to_non_nullable
as int,averagePaymentAmount: null == averagePaymentAmount ? _self.averagePaymentAmount : averagePaymentAmount // ignore: cast_nullable_to_non_nullable
as double,medianPaymentAmount: null == medianPaymentAmount ? _self.medianPaymentAmount : medianPaymentAmount // ignore: cast_nullable_to_non_nullable
as double,averagePaymentDays: null == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as int,activeCompanies: null == activeCompanies ? _self.activeCompanies : activeCompanies // ignore: cast_nullable_to_non_nullable
as int,companiesWithOverdue: null == companiesWithOverdue ? _self.companiesWithOverdue : companiesWithOverdue // ignore: cast_nullable_to_non_nullable
as int,companiesWithCredit: null == companiesWithCredit ? _self.companiesWithCredit : companiesWithCredit // ignore: cast_nullable_to_non_nullable
as int,revenueByPlan: freezed == revenueByPlan ? _self.revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self.revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByPaymentMethod: freezed == revenueByPaymentMethod ? _self.revenueByPaymentMethod : revenueByPaymentMethod // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,invoiceCountByStatus: freezed == invoiceCountByStatus ? _self.invoiceCountByStatus : invoiceCountByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,revenueByMonth: freezed == revenueByMonth ? _self.revenueByMonth : revenueByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,monthlyTrends: freezed == monthlyTrends ? _self.monthlyTrends : monthlyTrends // ignore: cast_nullable_to_non_nullable
as List<MonthlyRevenueTrend>?,topCompaniesByRevenue: freezed == topCompaniesByRevenue ? _self.topCompaniesByRevenue : topCompaniesByRevenue // ignore: cast_nullable_to_non_nullable
as List<CompanyRevenueRanking>?,topPlansByRevenue: freezed == topPlansByRevenue ? _self.topPlansByRevenue : topPlansByRevenue // ignore: cast_nullable_to_non_nullable
as List<PlanRevenueRanking>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reportData: freezed == reportData ? _self.reportData : reportData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueReport].
extension RevenueReportPatterns on RevenueReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueReport value)  $default,){
final _that = this;
switch (_that) {
case _RevenueReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueReport value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reportNumber,  String reportName,  ReportType type,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String generatedByAdminId,  String generatedByAdminName,  ReportStatus status,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  double refundedRevenue,  double creditNoteAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  int refundedInvoices,  int totalPayments,  double averagePaymentAmount,  double medianPaymentAmount,  int averagePaymentDays,  int activeCompanies,  int companiesWithOverdue,  int companiesWithCredit,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, double>? revenueByPaymentMethod,  Map<String, int>? invoiceCountByStatus,  Map<String, double>? revenueByMonth,  List<MonthlyRevenueTrend>? monthlyTrends,  List<CompanyRevenueRanking>? topCompaniesByRevenue,  List<PlanRevenueRanking>? topPlansByRevenue,  String? notes,  Map<String, dynamic>? reportData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueReport() when $default != null:
return $default(_that.id,_that.reportNumber,_that.reportName,_that.type,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.generatedByAdminId,_that.generatedByAdminName,_that.status,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.refundedRevenue,_that.creditNoteAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.refundedInvoices,_that.totalPayments,_that.averagePaymentAmount,_that.medianPaymentAmount,_that.averagePaymentDays,_that.activeCompanies,_that.companiesWithOverdue,_that.companiesWithCredit,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueByPaymentMethod,_that.invoiceCountByStatus,_that.revenueByMonth,_that.monthlyTrends,_that.topCompaniesByRevenue,_that.topPlansByRevenue,_that.notes,_that.reportData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reportNumber,  String reportName,  ReportType type,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String generatedByAdminId,  String generatedByAdminName,  ReportStatus status,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  double refundedRevenue,  double creditNoteAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  int refundedInvoices,  int totalPayments,  double averagePaymentAmount,  double medianPaymentAmount,  int averagePaymentDays,  int activeCompanies,  int companiesWithOverdue,  int companiesWithCredit,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, double>? revenueByPaymentMethod,  Map<String, int>? invoiceCountByStatus,  Map<String, double>? revenueByMonth,  List<MonthlyRevenueTrend>? monthlyTrends,  List<CompanyRevenueRanking>? topCompaniesByRevenue,  List<PlanRevenueRanking>? topPlansByRevenue,  String? notes,  Map<String, dynamic>? reportData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RevenueReport():
return $default(_that.id,_that.reportNumber,_that.reportName,_that.type,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.generatedByAdminId,_that.generatedByAdminName,_that.status,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.refundedRevenue,_that.creditNoteAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.refundedInvoices,_that.totalPayments,_that.averagePaymentAmount,_that.medianPaymentAmount,_that.averagePaymentDays,_that.activeCompanies,_that.companiesWithOverdue,_that.companiesWithCredit,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueByPaymentMethod,_that.invoiceCountByStatus,_that.revenueByMonth,_that.monthlyTrends,_that.topCompaniesByRevenue,_that.topPlansByRevenue,_that.notes,_that.reportData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reportNumber,  String reportName,  ReportType type,  DateTime periodStart,  DateTime periodEnd,  DateTime generatedAt,  String generatedByAdminId,  String generatedByAdminName,  ReportStatus status,  double totalRevenue,  double collectedRevenue,  double pendingRevenue,  double overdueRevenue,  double refundedRevenue,  double creditNoteAmount,  int totalInvoices,  int paidInvoices,  int pendingInvoices,  int overdueInvoices,  int draftInvoices,  int cancelledInvoices,  int refundedInvoices,  int totalPayments,  double averagePaymentAmount,  double medianPaymentAmount,  int averagePaymentDays,  int activeCompanies,  int companiesWithOverdue,  int companiesWithCredit,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType,  Map<String, double>? revenueByPaymentMethod,  Map<String, int>? invoiceCountByStatus,  Map<String, double>? revenueByMonth,  List<MonthlyRevenueTrend>? monthlyTrends,  List<CompanyRevenueRanking>? topCompaniesByRevenue,  List<PlanRevenueRanking>? topPlansByRevenue,  String? notes,  Map<String, dynamic>? reportData,  Map<String, dynamic>? metadata,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RevenueReport() when $default != null:
return $default(_that.id,_that.reportNumber,_that.reportName,_that.type,_that.periodStart,_that.periodEnd,_that.generatedAt,_that.generatedByAdminId,_that.generatedByAdminName,_that.status,_that.totalRevenue,_that.collectedRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.refundedRevenue,_that.creditNoteAmount,_that.totalInvoices,_that.paidInvoices,_that.pendingInvoices,_that.overdueInvoices,_that.draftInvoices,_that.cancelledInvoices,_that.refundedInvoices,_that.totalPayments,_that.averagePaymentAmount,_that.medianPaymentAmount,_that.averagePaymentDays,_that.activeCompanies,_that.companiesWithOverdue,_that.companiesWithCredit,_that.revenueByPlan,_that.revenueByCompanyType,_that.revenueByPaymentMethod,_that.invoiceCountByStatus,_that.revenueByMonth,_that.monthlyTrends,_that.topCompaniesByRevenue,_that.topPlansByRevenue,_that.notes,_that.reportData,_that.metadata,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueReport implements RevenueReport {
  const _RevenueReport({required this.id, required this.reportNumber, required this.reportName, required this.type, required this.periodStart, required this.periodEnd, required this.generatedAt, required this.generatedByAdminId, required this.generatedByAdminName, required this.status, required this.totalRevenue, required this.collectedRevenue, required this.pendingRevenue, required this.overdueRevenue, required this.refundedRevenue, required this.creditNoteAmount, required this.totalInvoices, required this.paidInvoices, required this.pendingInvoices, required this.overdueInvoices, required this.draftInvoices, required this.cancelledInvoices, required this.refundedInvoices, required this.totalPayments, required this.averagePaymentAmount, required this.medianPaymentAmount, required this.averagePaymentDays, required this.activeCompanies, required this.companiesWithOverdue, required this.companiesWithCredit, final  Map<String, double>? revenueByPlan, final  Map<String, double>? revenueByCompanyType, final  Map<String, double>? revenueByPaymentMethod, final  Map<String, int>? invoiceCountByStatus, final  Map<String, double>? revenueByMonth, final  List<MonthlyRevenueTrend>? monthlyTrends, final  List<CompanyRevenueRanking>? topCompaniesByRevenue, final  List<PlanRevenueRanking>? topPlansByRevenue, this.notes, final  Map<String, dynamic>? reportData, final  Map<String, dynamic>? metadata, this.createdAt, this.updatedAt}): _revenueByPlan = revenueByPlan,_revenueByCompanyType = revenueByCompanyType,_revenueByPaymentMethod = revenueByPaymentMethod,_invoiceCountByStatus = invoiceCountByStatus,_revenueByMonth = revenueByMonth,_monthlyTrends = monthlyTrends,_topCompaniesByRevenue = topCompaniesByRevenue,_topPlansByRevenue = topPlansByRevenue,_reportData = reportData,_metadata = metadata;
  factory _RevenueReport.fromJson(Map<String, dynamic> json) => _$RevenueReportFromJson(json);

@override final  String id;
@override final  String reportNumber;
@override final  String reportName;
@override final  ReportType type;
@override final  DateTime periodStart;
@override final  DateTime periodEnd;
@override final  DateTime generatedAt;
@override final  String generatedByAdminId;
@override final  String generatedByAdminName;
@override final  ReportStatus status;
// Revenue summary
@override final  double totalRevenue;
@override final  double collectedRevenue;
@override final  double pendingRevenue;
@override final  double overdueRevenue;
@override final  double refundedRevenue;
@override final  double creditNoteAmount;
// Invoice statistics
@override final  int totalInvoices;
@override final  int paidInvoices;
@override final  int pendingInvoices;
@override final  int overdueInvoices;
@override final  int draftInvoices;
@override final  int cancelledInvoices;
@override final  int refundedInvoices;
// Payment statistics
@override final  int totalPayments;
@override final  double averagePaymentAmount;
@override final  double medianPaymentAmount;
@override final  int averagePaymentDays;
// Company statistics
@override final  int activeCompanies;
@override final  int companiesWithOverdue;
@override final  int companiesWithCredit;
// Breakdowns
 final  Map<String, double>? _revenueByPlan;
// Breakdowns
@override Map<String, double>? get revenueByPlan {
  final value = _revenueByPlan;
  if (value == null) return null;
  if (_revenueByPlan is EqualUnmodifiableMapView) return _revenueByPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByCompanyType;
@override Map<String, double>? get revenueByCompanyType {
  final value = _revenueByCompanyType;
  if (value == null) return null;
  if (_revenueByCompanyType is EqualUnmodifiableMapView) return _revenueByCompanyType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByPaymentMethod;
@override Map<String, double>? get revenueByPaymentMethod {
  final value = _revenueByPaymentMethod;
  if (value == null) return null;
  if (_revenueByPaymentMethod is EqualUnmodifiableMapView) return _revenueByPaymentMethod;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _invoiceCountByStatus;
@override Map<String, int>? get invoiceCountByStatus {
  final value = _invoiceCountByStatus;
  if (value == null) return null;
  if (_invoiceCountByStatus is EqualUnmodifiableMapView) return _invoiceCountByStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByMonth;
@override Map<String, double>? get revenueByMonth {
  final value = _revenueByMonth;
  if (value == null) return null;
  if (_revenueByMonth is EqualUnmodifiableMapView) return _revenueByMonth;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Trend data
 final  List<MonthlyRevenueTrend>? _monthlyTrends;
// Trend data
@override List<MonthlyRevenueTrend>? get monthlyTrends {
  final value = _monthlyTrends;
  if (value == null) return null;
  if (_monthlyTrends is EqualUnmodifiableListView) return _monthlyTrends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<CompanyRevenueRanking>? _topCompaniesByRevenue;
@override List<CompanyRevenueRanking>? get topCompaniesByRevenue {
  final value = _topCompaniesByRevenue;
  if (value == null) return null;
  if (_topCompaniesByRevenue is EqualUnmodifiableListView) return _topCompaniesByRevenue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<PlanRevenueRanking>? _topPlansByRevenue;
@override List<PlanRevenueRanking>? get topPlansByRevenue {
  final value = _topPlansByRevenue;
  if (value == null) return null;
  if (_topPlansByRevenue is EqualUnmodifiableListView) return _topPlansByRevenue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Report details
@override final  String? notes;
 final  Map<String, dynamic>? _reportData;
@override Map<String, dynamic>? get reportData {
  final value = _reportData;
  if (value == null) return null;
  if (_reportData is EqualUnmodifiableMapView) return _reportData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RevenueReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueReportCopyWith<_RevenueReport> get copyWith => __$RevenueReportCopyWithImpl<_RevenueReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueReport&&(identical(other.id, id) || other.id == id)&&(identical(other.reportNumber, reportNumber) || other.reportNumber == reportNumber)&&(identical(other.reportName, reportName) || other.reportName == reportName)&&(identical(other.type, type) || other.type == type)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.generatedByAdminId, generatedByAdminId) || other.generatedByAdminId == generatedByAdminId)&&(identical(other.generatedByAdminName, generatedByAdminName) || other.generatedByAdminName == generatedByAdminName)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.refundedRevenue, refundedRevenue) || other.refundedRevenue == refundedRevenue)&&(identical(other.creditNoteAmount, creditNoteAmount) || other.creditNoteAmount == creditNoteAmount)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.pendingInvoices, pendingInvoices) || other.pendingInvoices == pendingInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.draftInvoices, draftInvoices) || other.draftInvoices == draftInvoices)&&(identical(other.cancelledInvoices, cancelledInvoices) || other.cancelledInvoices == cancelledInvoices)&&(identical(other.refundedInvoices, refundedInvoices) || other.refundedInvoices == refundedInvoices)&&(identical(other.totalPayments, totalPayments) || other.totalPayments == totalPayments)&&(identical(other.averagePaymentAmount, averagePaymentAmount) || other.averagePaymentAmount == averagePaymentAmount)&&(identical(other.medianPaymentAmount, medianPaymentAmount) || other.medianPaymentAmount == medianPaymentAmount)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.activeCompanies, activeCompanies) || other.activeCompanies == activeCompanies)&&(identical(other.companiesWithOverdue, companiesWithOverdue) || other.companiesWithOverdue == companiesWithOverdue)&&(identical(other.companiesWithCredit, companiesWithCredit) || other.companiesWithCredit == companiesWithCredit)&&const DeepCollectionEquality().equals(other._revenueByPlan, _revenueByPlan)&&const DeepCollectionEquality().equals(other._revenueByCompanyType, _revenueByCompanyType)&&const DeepCollectionEquality().equals(other._revenueByPaymentMethod, _revenueByPaymentMethod)&&const DeepCollectionEquality().equals(other._invoiceCountByStatus, _invoiceCountByStatus)&&const DeepCollectionEquality().equals(other._revenueByMonth, _revenueByMonth)&&const DeepCollectionEquality().equals(other._monthlyTrends, _monthlyTrends)&&const DeepCollectionEquality().equals(other._topCompaniesByRevenue, _topCompaniesByRevenue)&&const DeepCollectionEquality().equals(other._topPlansByRevenue, _topPlansByRevenue)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._reportData, _reportData)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportNumber,reportName,type,periodStart,periodEnd,generatedAt,generatedByAdminId,generatedByAdminName,status,totalRevenue,collectedRevenue,pendingRevenue,overdueRevenue,refundedRevenue,creditNoteAmount,totalInvoices,paidInvoices,pendingInvoices,overdueInvoices,draftInvoices,cancelledInvoices,refundedInvoices,totalPayments,averagePaymentAmount,medianPaymentAmount,averagePaymentDays,activeCompanies,companiesWithOverdue,companiesWithCredit,const DeepCollectionEquality().hash(_revenueByPlan),const DeepCollectionEquality().hash(_revenueByCompanyType),const DeepCollectionEquality().hash(_revenueByPaymentMethod),const DeepCollectionEquality().hash(_invoiceCountByStatus),const DeepCollectionEquality().hash(_revenueByMonth),const DeepCollectionEquality().hash(_monthlyTrends),const DeepCollectionEquality().hash(_topCompaniesByRevenue),const DeepCollectionEquality().hash(_topPlansByRevenue),notes,const DeepCollectionEquality().hash(_reportData),const DeepCollectionEquality().hash(_metadata),createdAt,updatedAt]);

@override
String toString() {
  return 'RevenueReport(id: $id, reportNumber: $reportNumber, reportName: $reportName, type: $type, periodStart: $periodStart, periodEnd: $periodEnd, generatedAt: $generatedAt, generatedByAdminId: $generatedByAdminId, generatedByAdminName: $generatedByAdminName, status: $status, totalRevenue: $totalRevenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, refundedRevenue: $refundedRevenue, creditNoteAmount: $creditNoteAmount, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, pendingInvoices: $pendingInvoices, overdueInvoices: $overdueInvoices, draftInvoices: $draftInvoices, cancelledInvoices: $cancelledInvoices, refundedInvoices: $refundedInvoices, totalPayments: $totalPayments, averagePaymentAmount: $averagePaymentAmount, medianPaymentAmount: $medianPaymentAmount, averagePaymentDays: $averagePaymentDays, activeCompanies: $activeCompanies, companiesWithOverdue: $companiesWithOverdue, companiesWithCredit: $companiesWithCredit, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType, revenueByPaymentMethod: $revenueByPaymentMethod, invoiceCountByStatus: $invoiceCountByStatus, revenueByMonth: $revenueByMonth, monthlyTrends: $monthlyTrends, topCompaniesByRevenue: $topCompaniesByRevenue, topPlansByRevenue: $topPlansByRevenue, notes: $notes, reportData: $reportData, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RevenueReportCopyWith<$Res> implements $RevenueReportCopyWith<$Res> {
  factory _$RevenueReportCopyWith(_RevenueReport value, $Res Function(_RevenueReport) _then) = __$RevenueReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String reportNumber, String reportName, ReportType type, DateTime periodStart, DateTime periodEnd, DateTime generatedAt, String generatedByAdminId, String generatedByAdminName, ReportStatus status, double totalRevenue, double collectedRevenue, double pendingRevenue, double overdueRevenue, double refundedRevenue, double creditNoteAmount, int totalInvoices, int paidInvoices, int pendingInvoices, int overdueInvoices, int draftInvoices, int cancelledInvoices, int refundedInvoices, int totalPayments, double averagePaymentAmount, double medianPaymentAmount, int averagePaymentDays, int activeCompanies, int companiesWithOverdue, int companiesWithCredit, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType, Map<String, double>? revenueByPaymentMethod, Map<String, int>? invoiceCountByStatus, Map<String, double>? revenueByMonth, List<MonthlyRevenueTrend>? monthlyTrends, List<CompanyRevenueRanking>? topCompaniesByRevenue, List<PlanRevenueRanking>? topPlansByRevenue, String? notes, Map<String, dynamic>? reportData, Map<String, dynamic>? metadata, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RevenueReportCopyWithImpl<$Res>
    implements _$RevenueReportCopyWith<$Res> {
  __$RevenueReportCopyWithImpl(this._self, this._then);

  final _RevenueReport _self;
  final $Res Function(_RevenueReport) _then;

/// Create a copy of RevenueReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportNumber = null,Object? reportName = null,Object? type = null,Object? periodStart = null,Object? periodEnd = null,Object? generatedAt = null,Object? generatedByAdminId = null,Object? generatedByAdminName = null,Object? status = null,Object? totalRevenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? refundedRevenue = null,Object? creditNoteAmount = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? pendingInvoices = null,Object? overdueInvoices = null,Object? draftInvoices = null,Object? cancelledInvoices = null,Object? refundedInvoices = null,Object? totalPayments = null,Object? averagePaymentAmount = null,Object? medianPaymentAmount = null,Object? averagePaymentDays = null,Object? activeCompanies = null,Object? companiesWithOverdue = null,Object? companiesWithCredit = null,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,Object? revenueByPaymentMethod = freezed,Object? invoiceCountByStatus = freezed,Object? revenueByMonth = freezed,Object? monthlyTrends = freezed,Object? topCompaniesByRevenue = freezed,Object? topPlansByRevenue = freezed,Object? notes = freezed,Object? reportData = freezed,Object? metadata = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RevenueReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportNumber: null == reportNumber ? _self.reportNumber : reportNumber // ignore: cast_nullable_to_non_nullable
as String,reportName: null == reportName ? _self.reportName : reportName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReportType,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,generatedByAdminId: null == generatedByAdminId ? _self.generatedByAdminId : generatedByAdminId // ignore: cast_nullable_to_non_nullable
as String,generatedByAdminName: null == generatedByAdminName ? _self.generatedByAdminName : generatedByAdminName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,refundedRevenue: null == refundedRevenue ? _self.refundedRevenue : refundedRevenue // ignore: cast_nullable_to_non_nullable
as double,creditNoteAmount: null == creditNoteAmount ? _self.creditNoteAmount : creditNoteAmount // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,pendingInvoices: null == pendingInvoices ? _self.pendingInvoices : pendingInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,draftInvoices: null == draftInvoices ? _self.draftInvoices : draftInvoices // ignore: cast_nullable_to_non_nullable
as int,cancelledInvoices: null == cancelledInvoices ? _self.cancelledInvoices : cancelledInvoices // ignore: cast_nullable_to_non_nullable
as int,refundedInvoices: null == refundedInvoices ? _self.refundedInvoices : refundedInvoices // ignore: cast_nullable_to_non_nullable
as int,totalPayments: null == totalPayments ? _self.totalPayments : totalPayments // ignore: cast_nullable_to_non_nullable
as int,averagePaymentAmount: null == averagePaymentAmount ? _self.averagePaymentAmount : averagePaymentAmount // ignore: cast_nullable_to_non_nullable
as double,medianPaymentAmount: null == medianPaymentAmount ? _self.medianPaymentAmount : medianPaymentAmount // ignore: cast_nullable_to_non_nullable
as double,averagePaymentDays: null == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as int,activeCompanies: null == activeCompanies ? _self.activeCompanies : activeCompanies // ignore: cast_nullable_to_non_nullable
as int,companiesWithOverdue: null == companiesWithOverdue ? _self.companiesWithOverdue : companiesWithOverdue // ignore: cast_nullable_to_non_nullable
as int,companiesWithCredit: null == companiesWithCredit ? _self.companiesWithCredit : companiesWithCredit // ignore: cast_nullable_to_non_nullable
as int,revenueByPlan: freezed == revenueByPlan ? _self._revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self._revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByPaymentMethod: freezed == revenueByPaymentMethod ? _self._revenueByPaymentMethod : revenueByPaymentMethod // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,invoiceCountByStatus: freezed == invoiceCountByStatus ? _self._invoiceCountByStatus : invoiceCountByStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,revenueByMonth: freezed == revenueByMonth ? _self._revenueByMonth : revenueByMonth // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,monthlyTrends: freezed == monthlyTrends ? _self._monthlyTrends : monthlyTrends // ignore: cast_nullable_to_non_nullable
as List<MonthlyRevenueTrend>?,topCompaniesByRevenue: freezed == topCompaniesByRevenue ? _self._topCompaniesByRevenue : topCompaniesByRevenue // ignore: cast_nullable_to_non_nullable
as List<CompanyRevenueRanking>?,topPlansByRevenue: freezed == topPlansByRevenue ? _self._topPlansByRevenue : topPlansByRevenue // ignore: cast_nullable_to_non_nullable
as List<PlanRevenueRanking>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,reportData: freezed == reportData ? _self._reportData : reportData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MonthlyRevenueTrend {

 int get year; int get month; String get monthName; double get revenue; double get collectedRevenue; double get pendingRevenue; int get invoiceCount; int get paidInvoiceCount; int get newCompanies; int get activeCompanies; double? get growthRate; double? get collectionRate; Map<String, double>? get revenueByPlan; Map<String, double>? get revenueByCompanyType;
/// Create a copy of MonthlyRevenueTrend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyRevenueTrendCopyWith<MonthlyRevenueTrend> get copyWith => _$MonthlyRevenueTrendCopyWithImpl<MonthlyRevenueTrend>(this as MonthlyRevenueTrend, _$identity);

  /// Serializes this MonthlyRevenueTrend to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyRevenueTrend&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.monthName, monthName) || other.monthName == monthName)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidInvoiceCount, paidInvoiceCount) || other.paidInvoiceCount == paidInvoiceCount)&&(identical(other.newCompanies, newCompanies) || other.newCompanies == newCompanies)&&(identical(other.activeCompanies, activeCompanies) || other.activeCompanies == activeCompanies)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&const DeepCollectionEquality().equals(other.revenueByPlan, revenueByPlan)&&const DeepCollectionEquality().equals(other.revenueByCompanyType, revenueByCompanyType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,monthName,revenue,collectedRevenue,pendingRevenue,invoiceCount,paidInvoiceCount,newCompanies,activeCompanies,growthRate,collectionRate,const DeepCollectionEquality().hash(revenueByPlan),const DeepCollectionEquality().hash(revenueByCompanyType));

@override
String toString() {
  return 'MonthlyRevenueTrend(year: $year, month: $month, monthName: $monthName, revenue: $revenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, invoiceCount: $invoiceCount, paidInvoiceCount: $paidInvoiceCount, newCompanies: $newCompanies, activeCompanies: $activeCompanies, growthRate: $growthRate, collectionRate: $collectionRate, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType)';
}


}

/// @nodoc
abstract mixin class $MonthlyRevenueTrendCopyWith<$Res>  {
  factory $MonthlyRevenueTrendCopyWith(MonthlyRevenueTrend value, $Res Function(MonthlyRevenueTrend) _then) = _$MonthlyRevenueTrendCopyWithImpl;
@useResult
$Res call({
 int year, int month, String monthName, double revenue, double collectedRevenue, double pendingRevenue, int invoiceCount, int paidInvoiceCount, int newCompanies, int activeCompanies, double? growthRate, double? collectionRate, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType
});




}
/// @nodoc
class _$MonthlyRevenueTrendCopyWithImpl<$Res>
    implements $MonthlyRevenueTrendCopyWith<$Res> {
  _$MonthlyRevenueTrendCopyWithImpl(this._self, this._then);

  final MonthlyRevenueTrend _self;
  final $Res Function(MonthlyRevenueTrend) _then;

/// Create a copy of MonthlyRevenueTrend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? monthName = null,Object? revenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? invoiceCount = null,Object? paidInvoiceCount = null,Object? newCompanies = null,Object? activeCompanies = null,Object? growthRate = freezed,Object? collectionRate = freezed,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,monthName: null == monthName ? _self.monthName : monthName // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidInvoiceCount: null == paidInvoiceCount ? _self.paidInvoiceCount : paidInvoiceCount // ignore: cast_nullable_to_non_nullable
as int,newCompanies: null == newCompanies ? _self.newCompanies : newCompanies // ignore: cast_nullable_to_non_nullable
as int,activeCompanies: null == activeCompanies ? _self.activeCompanies : activeCompanies // ignore: cast_nullable_to_non_nullable
as int,growthRate: freezed == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double?,collectionRate: freezed == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double?,revenueByPlan: freezed == revenueByPlan ? _self.revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self.revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyRevenueTrend].
extension MonthlyRevenueTrendPatterns on MonthlyRevenueTrend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyRevenueTrend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyRevenueTrend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyRevenueTrend value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyRevenueTrend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyRevenueTrend value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyRevenueTrend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  String monthName,  double revenue,  double collectedRevenue,  double pendingRevenue,  int invoiceCount,  int paidInvoiceCount,  int newCompanies,  int activeCompanies,  double? growthRate,  double? collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyRevenueTrend() when $default != null:
return $default(_that.year,_that.month,_that.monthName,_that.revenue,_that.collectedRevenue,_that.pendingRevenue,_that.invoiceCount,_that.paidInvoiceCount,_that.newCompanies,_that.activeCompanies,_that.growthRate,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  String monthName,  double revenue,  double collectedRevenue,  double pendingRevenue,  int invoiceCount,  int paidInvoiceCount,  int newCompanies,  int activeCompanies,  double? growthRate,  double? collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType)  $default,) {final _that = this;
switch (_that) {
case _MonthlyRevenueTrend():
return $default(_that.year,_that.month,_that.monthName,_that.revenue,_that.collectedRevenue,_that.pendingRevenue,_that.invoiceCount,_that.paidInvoiceCount,_that.newCompanies,_that.activeCompanies,_that.growthRate,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  String monthName,  double revenue,  double collectedRevenue,  double pendingRevenue,  int invoiceCount,  int paidInvoiceCount,  int newCompanies,  int activeCompanies,  double? growthRate,  double? collectionRate,  Map<String, double>? revenueByPlan,  Map<String, double>? revenueByCompanyType)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyRevenueTrend() when $default != null:
return $default(_that.year,_that.month,_that.monthName,_that.revenue,_that.collectedRevenue,_that.pendingRevenue,_that.invoiceCount,_that.paidInvoiceCount,_that.newCompanies,_that.activeCompanies,_that.growthRate,_that.collectionRate,_that.revenueByPlan,_that.revenueByCompanyType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyRevenueTrend implements MonthlyRevenueTrend {
  const _MonthlyRevenueTrend({required this.year, required this.month, required this.monthName, required this.revenue, required this.collectedRevenue, required this.pendingRevenue, required this.invoiceCount, required this.paidInvoiceCount, required this.newCompanies, required this.activeCompanies, this.growthRate, this.collectionRate, final  Map<String, double>? revenueByPlan, final  Map<String, double>? revenueByCompanyType}): _revenueByPlan = revenueByPlan,_revenueByCompanyType = revenueByCompanyType;
  factory _MonthlyRevenueTrend.fromJson(Map<String, dynamic> json) => _$MonthlyRevenueTrendFromJson(json);

@override final  int year;
@override final  int month;
@override final  String monthName;
@override final  double revenue;
@override final  double collectedRevenue;
@override final  double pendingRevenue;
@override final  int invoiceCount;
@override final  int paidInvoiceCount;
@override final  int newCompanies;
@override final  int activeCompanies;
@override final  double? growthRate;
@override final  double? collectionRate;
 final  Map<String, double>? _revenueByPlan;
@override Map<String, double>? get revenueByPlan {
  final value = _revenueByPlan;
  if (value == null) return null;
  if (_revenueByPlan is EqualUnmodifiableMapView) return _revenueByPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _revenueByCompanyType;
@override Map<String, double>? get revenueByCompanyType {
  final value = _revenueByCompanyType;
  if (value == null) return null;
  if (_revenueByCompanyType is EqualUnmodifiableMapView) return _revenueByCompanyType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of MonthlyRevenueTrend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyRevenueTrendCopyWith<_MonthlyRevenueTrend> get copyWith => __$MonthlyRevenueTrendCopyWithImpl<_MonthlyRevenueTrend>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyRevenueTrendToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyRevenueTrend&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.monthName, monthName) || other.monthName == monthName)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.collectedRevenue, collectedRevenue) || other.collectedRevenue == collectedRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.invoiceCount, invoiceCount) || other.invoiceCount == invoiceCount)&&(identical(other.paidInvoiceCount, paidInvoiceCount) || other.paidInvoiceCount == paidInvoiceCount)&&(identical(other.newCompanies, newCompanies) || other.newCompanies == newCompanies)&&(identical(other.activeCompanies, activeCompanies) || other.activeCompanies == activeCompanies)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&const DeepCollectionEquality().equals(other._revenueByPlan, _revenueByPlan)&&const DeepCollectionEquality().equals(other._revenueByCompanyType, _revenueByCompanyType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,monthName,revenue,collectedRevenue,pendingRevenue,invoiceCount,paidInvoiceCount,newCompanies,activeCompanies,growthRate,collectionRate,const DeepCollectionEquality().hash(_revenueByPlan),const DeepCollectionEquality().hash(_revenueByCompanyType));

@override
String toString() {
  return 'MonthlyRevenueTrend(year: $year, month: $month, monthName: $monthName, revenue: $revenue, collectedRevenue: $collectedRevenue, pendingRevenue: $pendingRevenue, invoiceCount: $invoiceCount, paidInvoiceCount: $paidInvoiceCount, newCompanies: $newCompanies, activeCompanies: $activeCompanies, growthRate: $growthRate, collectionRate: $collectionRate, revenueByPlan: $revenueByPlan, revenueByCompanyType: $revenueByCompanyType)';
}


}

/// @nodoc
abstract mixin class _$MonthlyRevenueTrendCopyWith<$Res> implements $MonthlyRevenueTrendCopyWith<$Res> {
  factory _$MonthlyRevenueTrendCopyWith(_MonthlyRevenueTrend value, $Res Function(_MonthlyRevenueTrend) _then) = __$MonthlyRevenueTrendCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, String monthName, double revenue, double collectedRevenue, double pendingRevenue, int invoiceCount, int paidInvoiceCount, int newCompanies, int activeCompanies, double? growthRate, double? collectionRate, Map<String, double>? revenueByPlan, Map<String, double>? revenueByCompanyType
});




}
/// @nodoc
class __$MonthlyRevenueTrendCopyWithImpl<$Res>
    implements _$MonthlyRevenueTrendCopyWith<$Res> {
  __$MonthlyRevenueTrendCopyWithImpl(this._self, this._then);

  final _MonthlyRevenueTrend _self;
  final $Res Function(_MonthlyRevenueTrend) _then;

/// Create a copy of MonthlyRevenueTrend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? monthName = null,Object? revenue = null,Object? collectedRevenue = null,Object? pendingRevenue = null,Object? invoiceCount = null,Object? paidInvoiceCount = null,Object? newCompanies = null,Object? activeCompanies = null,Object? growthRate = freezed,Object? collectionRate = freezed,Object? revenueByPlan = freezed,Object? revenueByCompanyType = freezed,}) {
  return _then(_MonthlyRevenueTrend(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,monthName: null == monthName ? _self.monthName : monthName // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,collectedRevenue: null == collectedRevenue ? _self.collectedRevenue : collectedRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,invoiceCount: null == invoiceCount ? _self.invoiceCount : invoiceCount // ignore: cast_nullable_to_non_nullable
as int,paidInvoiceCount: null == paidInvoiceCount ? _self.paidInvoiceCount : paidInvoiceCount // ignore: cast_nullable_to_non_nullable
as int,newCompanies: null == newCompanies ? _self.newCompanies : newCompanies // ignore: cast_nullable_to_non_nullable
as int,activeCompanies: null == activeCompanies ? _self.activeCompanies : activeCompanies // ignore: cast_nullable_to_non_nullable
as int,growthRate: freezed == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double?,collectionRate: freezed == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double?,revenueByPlan: freezed == revenueByPlan ? _self._revenueByPlan : revenueByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,revenueByCompanyType: freezed == revenueByCompanyType ? _self._revenueByCompanyType : revenueByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,
  ));
}


}


/// @nodoc
mixin _$CompanyRevenueRanking {

 String get companyId; String get companyName; String get companyType; double get totalRevenue; double get paidRevenue; double get pendingRevenue; double get overdueRevenue; int get totalInvoices; int get paidInvoices; int get overdueInvoices; String get currentPlan; DateTime? get subscriptionStart; DateTime? get subscriptionEnd; double? get averagePaymentDays; int? get ranking; double? get marketShare;
/// Create a copy of CompanyRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanyRevenueRankingCopyWith<CompanyRevenueRanking> get copyWith => _$CompanyRevenueRankingCopyWithImpl<CompanyRevenueRanking>(this as CompanyRevenueRanking, _$identity);

  /// Serializes this CompanyRevenueRanking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanyRevenueRanking&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.paidRevenue, paidRevenue) || other.paidRevenue == paidRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.subscriptionStart, subscriptionStart) || other.subscriptionStart == subscriptionStart)&&(identical(other.subscriptionEnd, subscriptionEnd) || other.subscriptionEnd == subscriptionEnd)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.ranking, ranking) || other.ranking == ranking)&&(identical(other.marketShare, marketShare) || other.marketShare == marketShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,companyName,companyType,totalRevenue,paidRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,overdueInvoices,currentPlan,subscriptionStart,subscriptionEnd,averagePaymentDays,ranking,marketShare);

@override
String toString() {
  return 'CompanyRevenueRanking(companyId: $companyId, companyName: $companyName, companyType: $companyType, totalRevenue: $totalRevenue, paidRevenue: $paidRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, currentPlan: $currentPlan, subscriptionStart: $subscriptionStart, subscriptionEnd: $subscriptionEnd, averagePaymentDays: $averagePaymentDays, ranking: $ranking, marketShare: $marketShare)';
}


}

/// @nodoc
abstract mixin class $CompanyRevenueRankingCopyWith<$Res>  {
  factory $CompanyRevenueRankingCopyWith(CompanyRevenueRanking value, $Res Function(CompanyRevenueRanking) _then) = _$CompanyRevenueRankingCopyWithImpl;
@useResult
$Res call({
 String companyId, String companyName, String companyType, double totalRevenue, double paidRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int overdueInvoices, String currentPlan, DateTime? subscriptionStart, DateTime? subscriptionEnd, double? averagePaymentDays, int? ranking, double? marketShare
});




}
/// @nodoc
class _$CompanyRevenueRankingCopyWithImpl<$Res>
    implements $CompanyRevenueRankingCopyWith<$Res> {
  _$CompanyRevenueRankingCopyWithImpl(this._self, this._then);

  final CompanyRevenueRanking _self;
  final $Res Function(CompanyRevenueRanking) _then;

/// Create a copy of CompanyRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? companyId = null,Object? companyName = null,Object? companyType = null,Object? totalRevenue = null,Object? paidRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? currentPlan = null,Object? subscriptionStart = freezed,Object? subscriptionEnd = freezed,Object? averagePaymentDays = freezed,Object? ranking = freezed,Object? marketShare = freezed,}) {
  return _then(_self.copyWith(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,companyType: null == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,paidRevenue: null == paidRevenue ? _self.paidRevenue : paidRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,currentPlan: null == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String,subscriptionStart: freezed == subscriptionStart ? _self.subscriptionStart : subscriptionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEnd: freezed == subscriptionEnd ? _self.subscriptionEnd : subscriptionEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,averagePaymentDays: freezed == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as double?,ranking: freezed == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as int?,marketShare: freezed == marketShare ? _self.marketShare : marketShare // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompanyRevenueRanking].
extension CompanyRevenueRankingPatterns on CompanyRevenueRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanyRevenueRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanyRevenueRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanyRevenueRanking value)  $default,){
final _that = this;
switch (_that) {
case _CompanyRevenueRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanyRevenueRanking value)?  $default,){
final _that = this;
switch (_that) {
case _CompanyRevenueRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  String currentPlan,  DateTime? subscriptionStart,  DateTime? subscriptionEnd,  double? averagePaymentDays,  int? ranking,  double? marketShare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanyRevenueRanking() when $default != null:
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.currentPlan,_that.subscriptionStart,_that.subscriptionEnd,_that.averagePaymentDays,_that.ranking,_that.marketShare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  String currentPlan,  DateTime? subscriptionStart,  DateTime? subscriptionEnd,  double? averagePaymentDays,  int? ranking,  double? marketShare)  $default,) {final _that = this;
switch (_that) {
case _CompanyRevenueRanking():
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.currentPlan,_that.subscriptionStart,_that.subscriptionEnd,_that.averagePaymentDays,_that.ranking,_that.marketShare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String companyId,  String companyName,  String companyType,  double totalRevenue,  double paidRevenue,  double pendingRevenue,  double overdueRevenue,  int totalInvoices,  int paidInvoices,  int overdueInvoices,  String currentPlan,  DateTime? subscriptionStart,  DateTime? subscriptionEnd,  double? averagePaymentDays,  int? ranking,  double? marketShare)?  $default,) {final _that = this;
switch (_that) {
case _CompanyRevenueRanking() when $default != null:
return $default(_that.companyId,_that.companyName,_that.companyType,_that.totalRevenue,_that.paidRevenue,_that.pendingRevenue,_that.overdueRevenue,_that.totalInvoices,_that.paidInvoices,_that.overdueInvoices,_that.currentPlan,_that.subscriptionStart,_that.subscriptionEnd,_that.averagePaymentDays,_that.ranking,_that.marketShare);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanyRevenueRanking implements CompanyRevenueRanking {
  const _CompanyRevenueRanking({required this.companyId, required this.companyName, required this.companyType, required this.totalRevenue, required this.paidRevenue, required this.pendingRevenue, required this.overdueRevenue, required this.totalInvoices, required this.paidInvoices, required this.overdueInvoices, required this.currentPlan, this.subscriptionStart, this.subscriptionEnd, this.averagePaymentDays, this.ranking, this.marketShare});
  factory _CompanyRevenueRanking.fromJson(Map<String, dynamic> json) => _$CompanyRevenueRankingFromJson(json);

@override final  String companyId;
@override final  String companyName;
@override final  String companyType;
@override final  double totalRevenue;
@override final  double paidRevenue;
@override final  double pendingRevenue;
@override final  double overdueRevenue;
@override final  int totalInvoices;
@override final  int paidInvoices;
@override final  int overdueInvoices;
@override final  String currentPlan;
@override final  DateTime? subscriptionStart;
@override final  DateTime? subscriptionEnd;
@override final  double? averagePaymentDays;
@override final  int? ranking;
@override final  double? marketShare;

/// Create a copy of CompanyRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyRevenueRankingCopyWith<_CompanyRevenueRanking> get copyWith => __$CompanyRevenueRankingCopyWithImpl<_CompanyRevenueRanking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanyRevenueRankingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyRevenueRanking&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.companyType, companyType) || other.companyType == companyType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.paidRevenue, paidRevenue) || other.paidRevenue == paidRevenue)&&(identical(other.pendingRevenue, pendingRevenue) || other.pendingRevenue == pendingRevenue)&&(identical(other.overdueRevenue, overdueRevenue) || other.overdueRevenue == overdueRevenue)&&(identical(other.totalInvoices, totalInvoices) || other.totalInvoices == totalInvoices)&&(identical(other.paidInvoices, paidInvoices) || other.paidInvoices == paidInvoices)&&(identical(other.overdueInvoices, overdueInvoices) || other.overdueInvoices == overdueInvoices)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.subscriptionStart, subscriptionStart) || other.subscriptionStart == subscriptionStart)&&(identical(other.subscriptionEnd, subscriptionEnd) || other.subscriptionEnd == subscriptionEnd)&&(identical(other.averagePaymentDays, averagePaymentDays) || other.averagePaymentDays == averagePaymentDays)&&(identical(other.ranking, ranking) || other.ranking == ranking)&&(identical(other.marketShare, marketShare) || other.marketShare == marketShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,companyId,companyName,companyType,totalRevenue,paidRevenue,pendingRevenue,overdueRevenue,totalInvoices,paidInvoices,overdueInvoices,currentPlan,subscriptionStart,subscriptionEnd,averagePaymentDays,ranking,marketShare);

@override
String toString() {
  return 'CompanyRevenueRanking(companyId: $companyId, companyName: $companyName, companyType: $companyType, totalRevenue: $totalRevenue, paidRevenue: $paidRevenue, pendingRevenue: $pendingRevenue, overdueRevenue: $overdueRevenue, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, overdueInvoices: $overdueInvoices, currentPlan: $currentPlan, subscriptionStart: $subscriptionStart, subscriptionEnd: $subscriptionEnd, averagePaymentDays: $averagePaymentDays, ranking: $ranking, marketShare: $marketShare)';
}


}

/// @nodoc
abstract mixin class _$CompanyRevenueRankingCopyWith<$Res> implements $CompanyRevenueRankingCopyWith<$Res> {
  factory _$CompanyRevenueRankingCopyWith(_CompanyRevenueRanking value, $Res Function(_CompanyRevenueRanking) _then) = __$CompanyRevenueRankingCopyWithImpl;
@override @useResult
$Res call({
 String companyId, String companyName, String companyType, double totalRevenue, double paidRevenue, double pendingRevenue, double overdueRevenue, int totalInvoices, int paidInvoices, int overdueInvoices, String currentPlan, DateTime? subscriptionStart, DateTime? subscriptionEnd, double? averagePaymentDays, int? ranking, double? marketShare
});




}
/// @nodoc
class __$CompanyRevenueRankingCopyWithImpl<$Res>
    implements _$CompanyRevenueRankingCopyWith<$Res> {
  __$CompanyRevenueRankingCopyWithImpl(this._self, this._then);

  final _CompanyRevenueRanking _self;
  final $Res Function(_CompanyRevenueRanking) _then;

/// Create a copy of CompanyRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? companyName = null,Object? companyType = null,Object? totalRevenue = null,Object? paidRevenue = null,Object? pendingRevenue = null,Object? overdueRevenue = null,Object? totalInvoices = null,Object? paidInvoices = null,Object? overdueInvoices = null,Object? currentPlan = null,Object? subscriptionStart = freezed,Object? subscriptionEnd = freezed,Object? averagePaymentDays = freezed,Object? ranking = freezed,Object? marketShare = freezed,}) {
  return _then(_CompanyRevenueRanking(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,companyType: null == companyType ? _self.companyType : companyType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,paidRevenue: null == paidRevenue ? _self.paidRevenue : paidRevenue // ignore: cast_nullable_to_non_nullable
as double,pendingRevenue: null == pendingRevenue ? _self.pendingRevenue : pendingRevenue // ignore: cast_nullable_to_non_nullable
as double,overdueRevenue: null == overdueRevenue ? _self.overdueRevenue : overdueRevenue // ignore: cast_nullable_to_non_nullable
as double,totalInvoices: null == totalInvoices ? _self.totalInvoices : totalInvoices // ignore: cast_nullable_to_non_nullable
as int,paidInvoices: null == paidInvoices ? _self.paidInvoices : paidInvoices // ignore: cast_nullable_to_non_nullable
as int,overdueInvoices: null == overdueInvoices ? _self.overdueInvoices : overdueInvoices // ignore: cast_nullable_to_non_nullable
as int,currentPlan: null == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String,subscriptionStart: freezed == subscriptionStart ? _self.subscriptionStart : subscriptionStart // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionEnd: freezed == subscriptionEnd ? _self.subscriptionEnd : subscriptionEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,averagePaymentDays: freezed == averagePaymentDays ? _self.averagePaymentDays : averagePaymentDays // ignore: cast_nullable_to_non_nullable
as double?,ranking: freezed == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as int?,marketShare: freezed == marketShare ? _self.marketShare : marketShare // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$PlanRevenueRanking {

 String get planId; String get planName; String get planType; double get totalRevenue; int get totalSubscriptions; int get activeSubscriptions; int get cancelledSubscriptions; double get averageRevenuePerSubscription; double get monthlyRecurringRevenue; double get annualRecurringRevenue; double? get churnRate; double? get upgradeRate; double? get downgradeRate; int? get ranking; double? get marketShare;
/// Create a copy of PlanRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanRevenueRankingCopyWith<PlanRevenueRanking> get copyWith => _$PlanRevenueRankingCopyWithImpl<PlanRevenueRanking>(this as PlanRevenueRanking, _$identity);

  /// Serializes this PlanRevenueRanking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanRevenueRanking&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalSubscriptions, totalSubscriptions) || other.totalSubscriptions == totalSubscriptions)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.cancelledSubscriptions, cancelledSubscriptions) || other.cancelledSubscriptions == cancelledSubscriptions)&&(identical(other.averageRevenuePerSubscription, averageRevenuePerSubscription) || other.averageRevenuePerSubscription == averageRevenuePerSubscription)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.upgradeRate, upgradeRate) || other.upgradeRate == upgradeRate)&&(identical(other.downgradeRate, downgradeRate) || other.downgradeRate == downgradeRate)&&(identical(other.ranking, ranking) || other.ranking == ranking)&&(identical(other.marketShare, marketShare) || other.marketShare == marketShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,planType,totalRevenue,totalSubscriptions,activeSubscriptions,cancelledSubscriptions,averageRevenuePerSubscription,monthlyRecurringRevenue,annualRecurringRevenue,churnRate,upgradeRate,downgradeRate,ranking,marketShare);

@override
String toString() {
  return 'PlanRevenueRanking(planId: $planId, planName: $planName, planType: $planType, totalRevenue: $totalRevenue, totalSubscriptions: $totalSubscriptions, activeSubscriptions: $activeSubscriptions, cancelledSubscriptions: $cancelledSubscriptions, averageRevenuePerSubscription: $averageRevenuePerSubscription, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, churnRate: $churnRate, upgradeRate: $upgradeRate, downgradeRate: $downgradeRate, ranking: $ranking, marketShare: $marketShare)';
}


}

/// @nodoc
abstract mixin class $PlanRevenueRankingCopyWith<$Res>  {
  factory $PlanRevenueRankingCopyWith(PlanRevenueRanking value, $Res Function(PlanRevenueRanking) _then) = _$PlanRevenueRankingCopyWithImpl;
@useResult
$Res call({
 String planId, String planName, String planType, double totalRevenue, int totalSubscriptions, int activeSubscriptions, int cancelledSubscriptions, double averageRevenuePerSubscription, double monthlyRecurringRevenue, double annualRecurringRevenue, double? churnRate, double? upgradeRate, double? downgradeRate, int? ranking, double? marketShare
});




}
/// @nodoc
class _$PlanRevenueRankingCopyWithImpl<$Res>
    implements $PlanRevenueRankingCopyWith<$Res> {
  _$PlanRevenueRankingCopyWithImpl(this._self, this._then);

  final PlanRevenueRanking _self;
  final $Res Function(PlanRevenueRanking) _then;

/// Create a copy of PlanRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? planId = null,Object? planName = null,Object? planType = null,Object? totalRevenue = null,Object? totalSubscriptions = null,Object? activeSubscriptions = null,Object? cancelledSubscriptions = null,Object? averageRevenuePerSubscription = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? churnRate = freezed,Object? upgradeRate = freezed,Object? downgradeRate = freezed,Object? ranking = freezed,Object? marketShare = freezed,}) {
  return _then(_self.copyWith(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalSubscriptions: null == totalSubscriptions ? _self.totalSubscriptions : totalSubscriptions // ignore: cast_nullable_to_non_nullable
as int,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,cancelledSubscriptions: null == cancelledSubscriptions ? _self.cancelledSubscriptions : cancelledSubscriptions // ignore: cast_nullable_to_non_nullable
as int,averageRevenuePerSubscription: null == averageRevenuePerSubscription ? _self.averageRevenuePerSubscription : averageRevenuePerSubscription // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,churnRate: freezed == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double?,upgradeRate: freezed == upgradeRate ? _self.upgradeRate : upgradeRate // ignore: cast_nullable_to_non_nullable
as double?,downgradeRate: freezed == downgradeRate ? _self.downgradeRate : downgradeRate // ignore: cast_nullable_to_non_nullable
as double?,ranking: freezed == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as int?,marketShare: freezed == marketShare ? _self.marketShare : marketShare // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanRevenueRanking].
extension PlanRevenueRankingPatterns on PlanRevenueRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanRevenueRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanRevenueRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanRevenueRanking value)  $default,){
final _that = this;
switch (_that) {
case _PlanRevenueRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanRevenueRanking value)?  $default,){
final _that = this;
switch (_that) {
case _PlanRevenueRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String planId,  String planName,  String planType,  double totalRevenue,  int totalSubscriptions,  int activeSubscriptions,  int cancelledSubscriptions,  double averageRevenuePerSubscription,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double? churnRate,  double? upgradeRate,  double? downgradeRate,  int? ranking,  double? marketShare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanRevenueRanking() when $default != null:
return $default(_that.planId,_that.planName,_that.planType,_that.totalRevenue,_that.totalSubscriptions,_that.activeSubscriptions,_that.cancelledSubscriptions,_that.averageRevenuePerSubscription,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.upgradeRate,_that.downgradeRate,_that.ranking,_that.marketShare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String planId,  String planName,  String planType,  double totalRevenue,  int totalSubscriptions,  int activeSubscriptions,  int cancelledSubscriptions,  double averageRevenuePerSubscription,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double? churnRate,  double? upgradeRate,  double? downgradeRate,  int? ranking,  double? marketShare)  $default,) {final _that = this;
switch (_that) {
case _PlanRevenueRanking():
return $default(_that.planId,_that.planName,_that.planType,_that.totalRevenue,_that.totalSubscriptions,_that.activeSubscriptions,_that.cancelledSubscriptions,_that.averageRevenuePerSubscription,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.upgradeRate,_that.downgradeRate,_that.ranking,_that.marketShare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String planId,  String planName,  String planType,  double totalRevenue,  int totalSubscriptions,  int activeSubscriptions,  int cancelledSubscriptions,  double averageRevenuePerSubscription,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double? churnRate,  double? upgradeRate,  double? downgradeRate,  int? ranking,  double? marketShare)?  $default,) {final _that = this;
switch (_that) {
case _PlanRevenueRanking() when $default != null:
return $default(_that.planId,_that.planName,_that.planType,_that.totalRevenue,_that.totalSubscriptions,_that.activeSubscriptions,_that.cancelledSubscriptions,_that.averageRevenuePerSubscription,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.churnRate,_that.upgradeRate,_that.downgradeRate,_that.ranking,_that.marketShare);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanRevenueRanking implements PlanRevenueRanking {
  const _PlanRevenueRanking({required this.planId, required this.planName, required this.planType, required this.totalRevenue, required this.totalSubscriptions, required this.activeSubscriptions, required this.cancelledSubscriptions, required this.averageRevenuePerSubscription, required this.monthlyRecurringRevenue, required this.annualRecurringRevenue, this.churnRate, this.upgradeRate, this.downgradeRate, this.ranking, this.marketShare});
  factory _PlanRevenueRanking.fromJson(Map<String, dynamic> json) => _$PlanRevenueRankingFromJson(json);

@override final  String planId;
@override final  String planName;
@override final  String planType;
@override final  double totalRevenue;
@override final  int totalSubscriptions;
@override final  int activeSubscriptions;
@override final  int cancelledSubscriptions;
@override final  double averageRevenuePerSubscription;
@override final  double monthlyRecurringRevenue;
@override final  double annualRecurringRevenue;
@override final  double? churnRate;
@override final  double? upgradeRate;
@override final  double? downgradeRate;
@override final  int? ranking;
@override final  double? marketShare;

/// Create a copy of PlanRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanRevenueRankingCopyWith<_PlanRevenueRanking> get copyWith => __$PlanRevenueRankingCopyWithImpl<_PlanRevenueRanking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanRevenueRankingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanRevenueRanking&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalSubscriptions, totalSubscriptions) || other.totalSubscriptions == totalSubscriptions)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.cancelledSubscriptions, cancelledSubscriptions) || other.cancelledSubscriptions == cancelledSubscriptions)&&(identical(other.averageRevenuePerSubscription, averageRevenuePerSubscription) || other.averageRevenuePerSubscription == averageRevenuePerSubscription)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.upgradeRate, upgradeRate) || other.upgradeRate == upgradeRate)&&(identical(other.downgradeRate, downgradeRate) || other.downgradeRate == downgradeRate)&&(identical(other.ranking, ranking) || other.ranking == ranking)&&(identical(other.marketShare, marketShare) || other.marketShare == marketShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,planName,planType,totalRevenue,totalSubscriptions,activeSubscriptions,cancelledSubscriptions,averageRevenuePerSubscription,monthlyRecurringRevenue,annualRecurringRevenue,churnRate,upgradeRate,downgradeRate,ranking,marketShare);

@override
String toString() {
  return 'PlanRevenueRanking(planId: $planId, planName: $planName, planType: $planType, totalRevenue: $totalRevenue, totalSubscriptions: $totalSubscriptions, activeSubscriptions: $activeSubscriptions, cancelledSubscriptions: $cancelledSubscriptions, averageRevenuePerSubscription: $averageRevenuePerSubscription, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, churnRate: $churnRate, upgradeRate: $upgradeRate, downgradeRate: $downgradeRate, ranking: $ranking, marketShare: $marketShare)';
}


}

/// @nodoc
abstract mixin class _$PlanRevenueRankingCopyWith<$Res> implements $PlanRevenueRankingCopyWith<$Res> {
  factory _$PlanRevenueRankingCopyWith(_PlanRevenueRanking value, $Res Function(_PlanRevenueRanking) _then) = __$PlanRevenueRankingCopyWithImpl;
@override @useResult
$Res call({
 String planId, String planName, String planType, double totalRevenue, int totalSubscriptions, int activeSubscriptions, int cancelledSubscriptions, double averageRevenuePerSubscription, double monthlyRecurringRevenue, double annualRecurringRevenue, double? churnRate, double? upgradeRate, double? downgradeRate, int? ranking, double? marketShare
});




}
/// @nodoc
class __$PlanRevenueRankingCopyWithImpl<$Res>
    implements _$PlanRevenueRankingCopyWith<$Res> {
  __$PlanRevenueRankingCopyWithImpl(this._self, this._then);

  final _PlanRevenueRanking _self;
  final $Res Function(_PlanRevenueRanking) _then;

/// Create a copy of PlanRevenueRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? planName = null,Object? planType = null,Object? totalRevenue = null,Object? totalSubscriptions = null,Object? activeSubscriptions = null,Object? cancelledSubscriptions = null,Object? averageRevenuePerSubscription = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? churnRate = freezed,Object? upgradeRate = freezed,Object? downgradeRate = freezed,Object? ranking = freezed,Object? marketShare = freezed,}) {
  return _then(_PlanRevenueRanking(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalSubscriptions: null == totalSubscriptions ? _self.totalSubscriptions : totalSubscriptions // ignore: cast_nullable_to_non_nullable
as int,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,cancelledSubscriptions: null == cancelledSubscriptions ? _self.cancelledSubscriptions : cancelledSubscriptions // ignore: cast_nullable_to_non_nullable
as int,averageRevenuePerSubscription: null == averageRevenuePerSubscription ? _self.averageRevenuePerSubscription : averageRevenuePerSubscription // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,churnRate: freezed == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double?,upgradeRate: freezed == upgradeRate ? _self.upgradeRate : upgradeRate // ignore: cast_nullable_to_non_nullable
as double?,downgradeRate: freezed == downgradeRate ? _self.downgradeRate : downgradeRate // ignore: cast_nullable_to_non_nullable
as double?,ranking: freezed == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as int?,marketShare: freezed == marketShare ? _self.marketShare : marketShare // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$RevenueForecast {

 DateTime get forecastDate; ForecastMethod get method; double get forecastedRevenue; double get lowerBound; double get upperBound; double get confidenceLevel; Map<String, double>? get forecastByPlan; Map<String, double>? get forecastByCompanyType; List<ForecastDataPoint>? get historicalData; List<ForecastDataPoint>? get forecastData; String? get notes; Map<String, dynamic>? get forecastParameters;
/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueForecastCopyWith<RevenueForecast> get copyWith => _$RevenueForecastCopyWithImpl<RevenueForecast>(this as RevenueForecast, _$identity);

  /// Serializes this RevenueForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueForecast&&(identical(other.forecastDate, forecastDate) || other.forecastDate == forecastDate)&&(identical(other.method, method) || other.method == method)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel)&&const DeepCollectionEquality().equals(other.forecastByPlan, forecastByPlan)&&const DeepCollectionEquality().equals(other.forecastByCompanyType, forecastByCompanyType)&&const DeepCollectionEquality().equals(other.historicalData, historicalData)&&const DeepCollectionEquality().equals(other.forecastData, forecastData)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.forecastParameters, forecastParameters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastDate,method,forecastedRevenue,lowerBound,upperBound,confidenceLevel,const DeepCollectionEquality().hash(forecastByPlan),const DeepCollectionEquality().hash(forecastByCompanyType),const DeepCollectionEquality().hash(historicalData),const DeepCollectionEquality().hash(forecastData),notes,const DeepCollectionEquality().hash(forecastParameters));

@override
String toString() {
  return 'RevenueForecast(forecastDate: $forecastDate, method: $method, forecastedRevenue: $forecastedRevenue, lowerBound: $lowerBound, upperBound: $upperBound, confidenceLevel: $confidenceLevel, forecastByPlan: $forecastByPlan, forecastByCompanyType: $forecastByCompanyType, historicalData: $historicalData, forecastData: $forecastData, notes: $notes, forecastParameters: $forecastParameters)';
}


}

/// @nodoc
abstract mixin class $RevenueForecastCopyWith<$Res>  {
  factory $RevenueForecastCopyWith(RevenueForecast value, $Res Function(RevenueForecast) _then) = _$RevenueForecastCopyWithImpl;
@useResult
$Res call({
 DateTime forecastDate, ForecastMethod method, double forecastedRevenue, double lowerBound, double upperBound, double confidenceLevel, Map<String, double>? forecastByPlan, Map<String, double>? forecastByCompanyType, List<ForecastDataPoint>? historicalData, List<ForecastDataPoint>? forecastData, String? notes, Map<String, dynamic>? forecastParameters
});




}
/// @nodoc
class _$RevenueForecastCopyWithImpl<$Res>
    implements $RevenueForecastCopyWith<$Res> {
  _$RevenueForecastCopyWithImpl(this._self, this._then);

  final RevenueForecast _self;
  final $Res Function(RevenueForecast) _then;

/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? forecastDate = null,Object? method = null,Object? forecastedRevenue = null,Object? lowerBound = null,Object? upperBound = null,Object? confidenceLevel = null,Object? forecastByPlan = freezed,Object? forecastByCompanyType = freezed,Object? historicalData = freezed,Object? forecastData = freezed,Object? notes = freezed,Object? forecastParameters = freezed,}) {
  return _then(_self.copyWith(
forecastDate: null == forecastDate ? _self.forecastDate : forecastDate // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ForecastMethod,forecastedRevenue: null == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,forecastByPlan: freezed == forecastByPlan ? _self.forecastByPlan : forecastByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,forecastByCompanyType: freezed == forecastByCompanyType ? _self.forecastByCompanyType : forecastByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,historicalData: freezed == historicalData ? _self.historicalData : historicalData // ignore: cast_nullable_to_non_nullable
as List<ForecastDataPoint>?,forecastData: freezed == forecastData ? _self.forecastData : forecastData // ignore: cast_nullable_to_non_nullable
as List<ForecastDataPoint>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,forecastParameters: freezed == forecastParameters ? _self.forecastParameters : forecastParameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueForecast].
extension RevenueForecastPatterns on RevenueForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueForecast value)  $default,){
final _that = this;
switch (_that) {
case _RevenueForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueForecast value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime forecastDate,  ForecastMethod method,  double forecastedRevenue,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByPlan,  Map<String, double>? forecastByCompanyType,  List<ForecastDataPoint>? historicalData,  List<ForecastDataPoint>? forecastData,  String? notes,  Map<String, dynamic>? forecastParameters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
return $default(_that.forecastDate,_that.method,_that.forecastedRevenue,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByPlan,_that.forecastByCompanyType,_that.historicalData,_that.forecastData,_that.notes,_that.forecastParameters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime forecastDate,  ForecastMethod method,  double forecastedRevenue,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByPlan,  Map<String, double>? forecastByCompanyType,  List<ForecastDataPoint>? historicalData,  List<ForecastDataPoint>? forecastData,  String? notes,  Map<String, dynamic>? forecastParameters)  $default,) {final _that = this;
switch (_that) {
case _RevenueForecast():
return $default(_that.forecastDate,_that.method,_that.forecastedRevenue,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByPlan,_that.forecastByCompanyType,_that.historicalData,_that.forecastData,_that.notes,_that.forecastParameters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime forecastDate,  ForecastMethod method,  double forecastedRevenue,  double lowerBound,  double upperBound,  double confidenceLevel,  Map<String, double>? forecastByPlan,  Map<String, double>? forecastByCompanyType,  List<ForecastDataPoint>? historicalData,  List<ForecastDataPoint>? forecastData,  String? notes,  Map<String, dynamic>? forecastParameters)?  $default,) {final _that = this;
switch (_that) {
case _RevenueForecast() when $default != null:
return $default(_that.forecastDate,_that.method,_that.forecastedRevenue,_that.lowerBound,_that.upperBound,_that.confidenceLevel,_that.forecastByPlan,_that.forecastByCompanyType,_that.historicalData,_that.forecastData,_that.notes,_that.forecastParameters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueForecast implements RevenueForecast {
  const _RevenueForecast({required this.forecastDate, required this.method, required this.forecastedRevenue, required this.lowerBound, required this.upperBound, required this.confidenceLevel, final  Map<String, double>? forecastByPlan, final  Map<String, double>? forecastByCompanyType, final  List<ForecastDataPoint>? historicalData, final  List<ForecastDataPoint>? forecastData, this.notes, final  Map<String, dynamic>? forecastParameters}): _forecastByPlan = forecastByPlan,_forecastByCompanyType = forecastByCompanyType,_historicalData = historicalData,_forecastData = forecastData,_forecastParameters = forecastParameters;
  factory _RevenueForecast.fromJson(Map<String, dynamic> json) => _$RevenueForecastFromJson(json);

@override final  DateTime forecastDate;
@override final  ForecastMethod method;
@override final  double forecastedRevenue;
@override final  double lowerBound;
@override final  double upperBound;
@override final  double confidenceLevel;
 final  Map<String, double>? _forecastByPlan;
@override Map<String, double>? get forecastByPlan {
  final value = _forecastByPlan;
  if (value == null) return null;
  if (_forecastByPlan is EqualUnmodifiableMapView) return _forecastByPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _forecastByCompanyType;
@override Map<String, double>? get forecastByCompanyType {
  final value = _forecastByCompanyType;
  if (value == null) return null;
  if (_forecastByCompanyType is EqualUnmodifiableMapView) return _forecastByCompanyType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<ForecastDataPoint>? _historicalData;
@override List<ForecastDataPoint>? get historicalData {
  final value = _historicalData;
  if (value == null) return null;
  if (_historicalData is EqualUnmodifiableListView) return _historicalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ForecastDataPoint>? _forecastData;
@override List<ForecastDataPoint>? get forecastData {
  final value = _forecastData;
  if (value == null) return null;
  if (_forecastData is EqualUnmodifiableListView) return _forecastData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? notes;
 final  Map<String, dynamic>? _forecastParameters;
@override Map<String, dynamic>? get forecastParameters {
  final value = _forecastParameters;
  if (value == null) return null;
  if (_forecastParameters is EqualUnmodifiableMapView) return _forecastParameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueForecastCopyWith<_RevenueForecast> get copyWith => __$RevenueForecastCopyWithImpl<_RevenueForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueForecastToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueForecast&&(identical(other.forecastDate, forecastDate) || other.forecastDate == forecastDate)&&(identical(other.method, method) || other.method == method)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.confidenceLevel, confidenceLevel) || other.confidenceLevel == confidenceLevel)&&const DeepCollectionEquality().equals(other._forecastByPlan, _forecastByPlan)&&const DeepCollectionEquality().equals(other._forecastByCompanyType, _forecastByCompanyType)&&const DeepCollectionEquality().equals(other._historicalData, _historicalData)&&const DeepCollectionEquality().equals(other._forecastData, _forecastData)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._forecastParameters, _forecastParameters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastDate,method,forecastedRevenue,lowerBound,upperBound,confidenceLevel,const DeepCollectionEquality().hash(_forecastByPlan),const DeepCollectionEquality().hash(_forecastByCompanyType),const DeepCollectionEquality().hash(_historicalData),const DeepCollectionEquality().hash(_forecastData),notes,const DeepCollectionEquality().hash(_forecastParameters));

@override
String toString() {
  return 'RevenueForecast(forecastDate: $forecastDate, method: $method, forecastedRevenue: $forecastedRevenue, lowerBound: $lowerBound, upperBound: $upperBound, confidenceLevel: $confidenceLevel, forecastByPlan: $forecastByPlan, forecastByCompanyType: $forecastByCompanyType, historicalData: $historicalData, forecastData: $forecastData, notes: $notes, forecastParameters: $forecastParameters)';
}


}

/// @nodoc
abstract mixin class _$RevenueForecastCopyWith<$Res> implements $RevenueForecastCopyWith<$Res> {
  factory _$RevenueForecastCopyWith(_RevenueForecast value, $Res Function(_RevenueForecast) _then) = __$RevenueForecastCopyWithImpl;
@override @useResult
$Res call({
 DateTime forecastDate, ForecastMethod method, double forecastedRevenue, double lowerBound, double upperBound, double confidenceLevel, Map<String, double>? forecastByPlan, Map<String, double>? forecastByCompanyType, List<ForecastDataPoint>? historicalData, List<ForecastDataPoint>? forecastData, String? notes, Map<String, dynamic>? forecastParameters
});




}
/// @nodoc
class __$RevenueForecastCopyWithImpl<$Res>
    implements _$RevenueForecastCopyWith<$Res> {
  __$RevenueForecastCopyWithImpl(this._self, this._then);

  final _RevenueForecast _self;
  final $Res Function(_RevenueForecast) _then;

/// Create a copy of RevenueForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? forecastDate = null,Object? method = null,Object? forecastedRevenue = null,Object? lowerBound = null,Object? upperBound = null,Object? confidenceLevel = null,Object? forecastByPlan = freezed,Object? forecastByCompanyType = freezed,Object? historicalData = freezed,Object? forecastData = freezed,Object? notes = freezed,Object? forecastParameters = freezed,}) {
  return _then(_RevenueForecast(
forecastDate: null == forecastDate ? _self.forecastDate : forecastDate // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ForecastMethod,forecastedRevenue: null == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,confidenceLevel: null == confidenceLevel ? _self.confidenceLevel : confidenceLevel // ignore: cast_nullable_to_non_nullable
as double,forecastByPlan: freezed == forecastByPlan ? _self._forecastByPlan : forecastByPlan // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,forecastByCompanyType: freezed == forecastByCompanyType ? _self._forecastByCompanyType : forecastByCompanyType // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,historicalData: freezed == historicalData ? _self._historicalData : historicalData // ignore: cast_nullable_to_non_nullable
as List<ForecastDataPoint>?,forecastData: freezed == forecastData ? _self._forecastData : forecastData // ignore: cast_nullable_to_non_nullable
as List<ForecastDataPoint>?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,forecastParameters: freezed == forecastParameters ? _self._forecastParameters : forecastParameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ForecastDataPoint {

 DateTime get date; double get actualRevenue; double? get forecastedRevenue; double? get forecastError; double? get lowerBound; double? get upperBound;
/// Create a copy of ForecastDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastDataPointCopyWith<ForecastDataPoint> get copyWith => _$ForecastDataPointCopyWithImpl<ForecastDataPoint>(this as ForecastDataPoint, _$identity);

  /// Serializes this ForecastDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForecastDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.actualRevenue, actualRevenue) || other.actualRevenue == actualRevenue)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.forecastError, forecastError) || other.forecastError == forecastError)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,actualRevenue,forecastedRevenue,forecastError,lowerBound,upperBound);

@override
String toString() {
  return 'ForecastDataPoint(date: $date, actualRevenue: $actualRevenue, forecastedRevenue: $forecastedRevenue, forecastError: $forecastError, lowerBound: $lowerBound, upperBound: $upperBound)';
}


}

/// @nodoc
abstract mixin class $ForecastDataPointCopyWith<$Res>  {
  factory $ForecastDataPointCopyWith(ForecastDataPoint value, $Res Function(ForecastDataPoint) _then) = _$ForecastDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double actualRevenue, double? forecastedRevenue, double? forecastError, double? lowerBound, double? upperBound
});




}
/// @nodoc
class _$ForecastDataPointCopyWithImpl<$Res>
    implements $ForecastDataPointCopyWith<$Res> {
  _$ForecastDataPointCopyWithImpl(this._self, this._then);

  final ForecastDataPoint _self;
  final $Res Function(ForecastDataPoint) _then;

/// Create a copy of ForecastDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? actualRevenue = null,Object? forecastedRevenue = freezed,Object? forecastError = freezed,Object? lowerBound = freezed,Object? upperBound = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,actualRevenue: null == actualRevenue ? _self.actualRevenue : actualRevenue // ignore: cast_nullable_to_non_nullable
as double,forecastedRevenue: freezed == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double?,forecastError: freezed == forecastError ? _self.forecastError : forecastError // ignore: cast_nullable_to_non_nullable
as double?,lowerBound: freezed == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double?,upperBound: freezed == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForecastDataPoint].
extension ForecastDataPointPatterns on ForecastDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForecastDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForecastDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForecastDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _ForecastDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForecastDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ForecastDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double actualRevenue,  double? forecastedRevenue,  double? forecastError,  double? lowerBound,  double? upperBound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForecastDataPoint() when $default != null:
return $default(_that.date,_that.actualRevenue,_that.forecastedRevenue,_that.forecastError,_that.lowerBound,_that.upperBound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double actualRevenue,  double? forecastedRevenue,  double? forecastError,  double? lowerBound,  double? upperBound)  $default,) {final _that = this;
switch (_that) {
case _ForecastDataPoint():
return $default(_that.date,_that.actualRevenue,_that.forecastedRevenue,_that.forecastError,_that.lowerBound,_that.upperBound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double actualRevenue,  double? forecastedRevenue,  double? forecastError,  double? lowerBound,  double? upperBound)?  $default,) {final _that = this;
switch (_that) {
case _ForecastDataPoint() when $default != null:
return $default(_that.date,_that.actualRevenue,_that.forecastedRevenue,_that.forecastError,_that.lowerBound,_that.upperBound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForecastDataPoint implements ForecastDataPoint {
  const _ForecastDataPoint({required this.date, required this.actualRevenue, this.forecastedRevenue, this.forecastError, this.lowerBound, this.upperBound});
  factory _ForecastDataPoint.fromJson(Map<String, dynamic> json) => _$ForecastDataPointFromJson(json);

@override final  DateTime date;
@override final  double actualRevenue;
@override final  double? forecastedRevenue;
@override final  double? forecastError;
@override final  double? lowerBound;
@override final  double? upperBound;

/// Create a copy of ForecastDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastDataPointCopyWith<_ForecastDataPoint> get copyWith => __$ForecastDataPointCopyWithImpl<_ForecastDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForecastDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.actualRevenue, actualRevenue) || other.actualRevenue == actualRevenue)&&(identical(other.forecastedRevenue, forecastedRevenue) || other.forecastedRevenue == forecastedRevenue)&&(identical(other.forecastError, forecastError) || other.forecastError == forecastError)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,actualRevenue,forecastedRevenue,forecastError,lowerBound,upperBound);

@override
String toString() {
  return 'ForecastDataPoint(date: $date, actualRevenue: $actualRevenue, forecastedRevenue: $forecastedRevenue, forecastError: $forecastError, lowerBound: $lowerBound, upperBound: $upperBound)';
}


}

/// @nodoc
abstract mixin class _$ForecastDataPointCopyWith<$Res> implements $ForecastDataPointCopyWith<$Res> {
  factory _$ForecastDataPointCopyWith(_ForecastDataPoint value, $Res Function(_ForecastDataPoint) _then) = __$ForecastDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double actualRevenue, double? forecastedRevenue, double? forecastError, double? lowerBound, double? upperBound
});




}
/// @nodoc
class __$ForecastDataPointCopyWithImpl<$Res>
    implements _$ForecastDataPointCopyWith<$Res> {
  __$ForecastDataPointCopyWithImpl(this._self, this._then);

  final _ForecastDataPoint _self;
  final $Res Function(_ForecastDataPoint) _then;

/// Create a copy of ForecastDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? actualRevenue = null,Object? forecastedRevenue = freezed,Object? forecastError = freezed,Object? lowerBound = freezed,Object? upperBound = freezed,}) {
  return _then(_ForecastDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,actualRevenue: null == actualRevenue ? _self.actualRevenue : actualRevenue // ignore: cast_nullable_to_non_nullable
as double,forecastedRevenue: freezed == forecastedRevenue ? _self.forecastedRevenue : forecastedRevenue // ignore: cast_nullable_to_non_nullable
as double?,forecastError: freezed == forecastError ? _self.forecastError : forecastError // ignore: cast_nullable_to_non_nullable
as double?,lowerBound: freezed == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double?,upperBound: freezed == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$RevenueAnalysis {

 DateTime get analysisDate; AnalysisPeriod get period; double get totalRevenue; double get revenueGrowth; double get revenueGrowthRate; double get collectionRate; double get churnRate; double get expansionRate; double get netRevenueRetention; double get grossRevenueRetention;// Key metrics
 double get monthlyRecurringRevenue; double get annualRecurringRevenue; double get averageRevenuePerUser; double get lifetimeValue; double get customerAcquisitionCost;// Segment analysis
 Map<String, double>? get revenueBySegment; Map<String, double>? get growthBySegment; Map<String, double>? get churnBySegment;// Trend analysis
 List<RevenueMetricTrend>? get metricTrends; List<RevenueDriverAnalysis>? get driverAnalysis;// Insights
 List<RevenueInsight>? get insights; List<RevenueRecommendation>? get recommendations; String? get summary; Map<String, dynamic>? get analysisData;
/// Create a copy of RevenueAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueAnalysisCopyWith<RevenueAnalysis> get copyWith => _$RevenueAnalysisCopyWithImpl<RevenueAnalysis>(this as RevenueAnalysis, _$identity);

  /// Serializes this RevenueAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueAnalysis&&(identical(other.analysisDate, analysisDate) || other.analysisDate == analysisDate)&&(identical(other.period, period) || other.period == period)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.revenueGrowth, revenueGrowth) || other.revenueGrowth == revenueGrowth)&&(identical(other.revenueGrowthRate, revenueGrowthRate) || other.revenueGrowthRate == revenueGrowthRate)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.expansionRate, expansionRate) || other.expansionRate == expansionRate)&&(identical(other.netRevenueRetention, netRevenueRetention) || other.netRevenueRetention == netRevenueRetention)&&(identical(other.grossRevenueRetention, grossRevenueRetention) || other.grossRevenueRetention == grossRevenueRetention)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.averageRevenuePerUser, averageRevenuePerUser) || other.averageRevenuePerUser == averageRevenuePerUser)&&(identical(other.lifetimeValue, lifetimeValue) || other.lifetimeValue == lifetimeValue)&&(identical(other.customerAcquisitionCost, customerAcquisitionCost) || other.customerAcquisitionCost == customerAcquisitionCost)&&const DeepCollectionEquality().equals(other.revenueBySegment, revenueBySegment)&&const DeepCollectionEquality().equals(other.growthBySegment, growthBySegment)&&const DeepCollectionEquality().equals(other.churnBySegment, churnBySegment)&&const DeepCollectionEquality().equals(other.metricTrends, metricTrends)&&const DeepCollectionEquality().equals(other.driverAnalysis, driverAnalysis)&&const DeepCollectionEquality().equals(other.insights, insights)&&const DeepCollectionEquality().equals(other.recommendations, recommendations)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.analysisData, analysisData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,analysisDate,period,totalRevenue,revenueGrowth,revenueGrowthRate,collectionRate,churnRate,expansionRate,netRevenueRetention,grossRevenueRetention,monthlyRecurringRevenue,annualRecurringRevenue,averageRevenuePerUser,lifetimeValue,customerAcquisitionCost,const DeepCollectionEquality().hash(revenueBySegment),const DeepCollectionEquality().hash(growthBySegment),const DeepCollectionEquality().hash(churnBySegment),const DeepCollectionEquality().hash(metricTrends),const DeepCollectionEquality().hash(driverAnalysis),const DeepCollectionEquality().hash(insights),const DeepCollectionEquality().hash(recommendations),summary,const DeepCollectionEquality().hash(analysisData)]);

@override
String toString() {
  return 'RevenueAnalysis(analysisDate: $analysisDate, period: $period, totalRevenue: $totalRevenue, revenueGrowth: $revenueGrowth, revenueGrowthRate: $revenueGrowthRate, collectionRate: $collectionRate, churnRate: $churnRate, expansionRate: $expansionRate, netRevenueRetention: $netRevenueRetention, grossRevenueRetention: $grossRevenueRetention, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, averageRevenuePerUser: $averageRevenuePerUser, lifetimeValue: $lifetimeValue, customerAcquisitionCost: $customerAcquisitionCost, revenueBySegment: $revenueBySegment, growthBySegment: $growthBySegment, churnBySegment: $churnBySegment, metricTrends: $metricTrends, driverAnalysis: $driverAnalysis, insights: $insights, recommendations: $recommendations, summary: $summary, analysisData: $analysisData)';
}


}

/// @nodoc
abstract mixin class $RevenueAnalysisCopyWith<$Res>  {
  factory $RevenueAnalysisCopyWith(RevenueAnalysis value, $Res Function(RevenueAnalysis) _then) = _$RevenueAnalysisCopyWithImpl;
@useResult
$Res call({
 DateTime analysisDate, AnalysisPeriod period, double totalRevenue, double revenueGrowth, double revenueGrowthRate, double collectionRate, double churnRate, double expansionRate, double netRevenueRetention, double grossRevenueRetention, double monthlyRecurringRevenue, double annualRecurringRevenue, double averageRevenuePerUser, double lifetimeValue, double customerAcquisitionCost, Map<String, double>? revenueBySegment, Map<String, double>? growthBySegment, Map<String, double>? churnBySegment, List<RevenueMetricTrend>? metricTrends, List<RevenueDriverAnalysis>? driverAnalysis, List<RevenueInsight>? insights, List<RevenueRecommendation>? recommendations, String? summary, Map<String, dynamic>? analysisData
});




}
/// @nodoc
class _$RevenueAnalysisCopyWithImpl<$Res>
    implements $RevenueAnalysisCopyWith<$Res> {
  _$RevenueAnalysisCopyWithImpl(this._self, this._then);

  final RevenueAnalysis _self;
  final $Res Function(RevenueAnalysis) _then;

/// Create a copy of RevenueAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? analysisDate = null,Object? period = null,Object? totalRevenue = null,Object? revenueGrowth = null,Object? revenueGrowthRate = null,Object? collectionRate = null,Object? churnRate = null,Object? expansionRate = null,Object? netRevenueRetention = null,Object? grossRevenueRetention = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? averageRevenuePerUser = null,Object? lifetimeValue = null,Object? customerAcquisitionCost = null,Object? revenueBySegment = freezed,Object? growthBySegment = freezed,Object? churnBySegment = freezed,Object? metricTrends = freezed,Object? driverAnalysis = freezed,Object? insights = freezed,Object? recommendations = freezed,Object? summary = freezed,Object? analysisData = freezed,}) {
  return _then(_self.copyWith(
analysisDate: null == analysisDate ? _self.analysisDate : analysisDate // ignore: cast_nullable_to_non_nullable
as DateTime,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalysisPeriod,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueGrowth: null == revenueGrowth ? _self.revenueGrowth : revenueGrowth // ignore: cast_nullable_to_non_nullable
as double,revenueGrowthRate: null == revenueGrowthRate ? _self.revenueGrowthRate : revenueGrowthRate // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,churnRate: null == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double,expansionRate: null == expansionRate ? _self.expansionRate : expansionRate // ignore: cast_nullable_to_non_nullable
as double,netRevenueRetention: null == netRevenueRetention ? _self.netRevenueRetention : netRevenueRetention // ignore: cast_nullable_to_non_nullable
as double,grossRevenueRetention: null == grossRevenueRetention ? _self.grossRevenueRetention : grossRevenueRetention // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,averageRevenuePerUser: null == averageRevenuePerUser ? _self.averageRevenuePerUser : averageRevenuePerUser // ignore: cast_nullable_to_non_nullable
as double,lifetimeValue: null == lifetimeValue ? _self.lifetimeValue : lifetimeValue // ignore: cast_nullable_to_non_nullable
as double,customerAcquisitionCost: null == customerAcquisitionCost ? _self.customerAcquisitionCost : customerAcquisitionCost // ignore: cast_nullable_to_non_nullable
as double,revenueBySegment: freezed == revenueBySegment ? _self.revenueBySegment : revenueBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,growthBySegment: freezed == growthBySegment ? _self.growthBySegment : growthBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,churnBySegment: freezed == churnBySegment ? _self.churnBySegment : churnBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,metricTrends: freezed == metricTrends ? _self.metricTrends : metricTrends // ignore: cast_nullable_to_non_nullable
as List<RevenueMetricTrend>?,driverAnalysis: freezed == driverAnalysis ? _self.driverAnalysis : driverAnalysis // ignore: cast_nullable_to_non_nullable
as List<RevenueDriverAnalysis>?,insights: freezed == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as List<RevenueInsight>?,recommendations: freezed == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<RevenueRecommendation>?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,analysisData: freezed == analysisData ? _self.analysisData : analysisData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueAnalysis].
extension RevenueAnalysisPatterns on RevenueAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _RevenueAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime analysisDate,  AnalysisPeriod period,  double totalRevenue,  double revenueGrowth,  double revenueGrowthRate,  double collectionRate,  double churnRate,  double expansionRate,  double netRevenueRetention,  double grossRevenueRetention,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double averageRevenuePerUser,  double lifetimeValue,  double customerAcquisitionCost,  Map<String, double>? revenueBySegment,  Map<String, double>? growthBySegment,  Map<String, double>? churnBySegment,  List<RevenueMetricTrend>? metricTrends,  List<RevenueDriverAnalysis>? driverAnalysis,  List<RevenueInsight>? insights,  List<RevenueRecommendation>? recommendations,  String? summary,  Map<String, dynamic>? analysisData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueAnalysis() when $default != null:
return $default(_that.analysisDate,_that.period,_that.totalRevenue,_that.revenueGrowth,_that.revenueGrowthRate,_that.collectionRate,_that.churnRate,_that.expansionRate,_that.netRevenueRetention,_that.grossRevenueRetention,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.averageRevenuePerUser,_that.lifetimeValue,_that.customerAcquisitionCost,_that.revenueBySegment,_that.growthBySegment,_that.churnBySegment,_that.metricTrends,_that.driverAnalysis,_that.insights,_that.recommendations,_that.summary,_that.analysisData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime analysisDate,  AnalysisPeriod period,  double totalRevenue,  double revenueGrowth,  double revenueGrowthRate,  double collectionRate,  double churnRate,  double expansionRate,  double netRevenueRetention,  double grossRevenueRetention,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double averageRevenuePerUser,  double lifetimeValue,  double customerAcquisitionCost,  Map<String, double>? revenueBySegment,  Map<String, double>? growthBySegment,  Map<String, double>? churnBySegment,  List<RevenueMetricTrend>? metricTrends,  List<RevenueDriverAnalysis>? driverAnalysis,  List<RevenueInsight>? insights,  List<RevenueRecommendation>? recommendations,  String? summary,  Map<String, dynamic>? analysisData)  $default,) {final _that = this;
switch (_that) {
case _RevenueAnalysis():
return $default(_that.analysisDate,_that.period,_that.totalRevenue,_that.revenueGrowth,_that.revenueGrowthRate,_that.collectionRate,_that.churnRate,_that.expansionRate,_that.netRevenueRetention,_that.grossRevenueRetention,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.averageRevenuePerUser,_that.lifetimeValue,_that.customerAcquisitionCost,_that.revenueBySegment,_that.growthBySegment,_that.churnBySegment,_that.metricTrends,_that.driverAnalysis,_that.insights,_that.recommendations,_that.summary,_that.analysisData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime analysisDate,  AnalysisPeriod period,  double totalRevenue,  double revenueGrowth,  double revenueGrowthRate,  double collectionRate,  double churnRate,  double expansionRate,  double netRevenueRetention,  double grossRevenueRetention,  double monthlyRecurringRevenue,  double annualRecurringRevenue,  double averageRevenuePerUser,  double lifetimeValue,  double customerAcquisitionCost,  Map<String, double>? revenueBySegment,  Map<String, double>? growthBySegment,  Map<String, double>? churnBySegment,  List<RevenueMetricTrend>? metricTrends,  List<RevenueDriverAnalysis>? driverAnalysis,  List<RevenueInsight>? insights,  List<RevenueRecommendation>? recommendations,  String? summary,  Map<String, dynamic>? analysisData)?  $default,) {final _that = this;
switch (_that) {
case _RevenueAnalysis() when $default != null:
return $default(_that.analysisDate,_that.period,_that.totalRevenue,_that.revenueGrowth,_that.revenueGrowthRate,_that.collectionRate,_that.churnRate,_that.expansionRate,_that.netRevenueRetention,_that.grossRevenueRetention,_that.monthlyRecurringRevenue,_that.annualRecurringRevenue,_that.averageRevenuePerUser,_that.lifetimeValue,_that.customerAcquisitionCost,_that.revenueBySegment,_that.growthBySegment,_that.churnBySegment,_that.metricTrends,_that.driverAnalysis,_that.insights,_that.recommendations,_that.summary,_that.analysisData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueAnalysis implements RevenueAnalysis {
  const _RevenueAnalysis({required this.analysisDate, required this.period, required this.totalRevenue, required this.revenueGrowth, required this.revenueGrowthRate, required this.collectionRate, required this.churnRate, required this.expansionRate, required this.netRevenueRetention, required this.grossRevenueRetention, required this.monthlyRecurringRevenue, required this.annualRecurringRevenue, required this.averageRevenuePerUser, required this.lifetimeValue, required this.customerAcquisitionCost, final  Map<String, double>? revenueBySegment, final  Map<String, double>? growthBySegment, final  Map<String, double>? churnBySegment, final  List<RevenueMetricTrend>? metricTrends, final  List<RevenueDriverAnalysis>? driverAnalysis, final  List<RevenueInsight>? insights, final  List<RevenueRecommendation>? recommendations, this.summary, final  Map<String, dynamic>? analysisData}): _revenueBySegment = revenueBySegment,_growthBySegment = growthBySegment,_churnBySegment = churnBySegment,_metricTrends = metricTrends,_driverAnalysis = driverAnalysis,_insights = insights,_recommendations = recommendations,_analysisData = analysisData;
  factory _RevenueAnalysis.fromJson(Map<String, dynamic> json) => _$RevenueAnalysisFromJson(json);

@override final  DateTime analysisDate;
@override final  AnalysisPeriod period;
@override final  double totalRevenue;
@override final  double revenueGrowth;
@override final  double revenueGrowthRate;
@override final  double collectionRate;
@override final  double churnRate;
@override final  double expansionRate;
@override final  double netRevenueRetention;
@override final  double grossRevenueRetention;
// Key metrics
@override final  double monthlyRecurringRevenue;
@override final  double annualRecurringRevenue;
@override final  double averageRevenuePerUser;
@override final  double lifetimeValue;
@override final  double customerAcquisitionCost;
// Segment analysis
 final  Map<String, double>? _revenueBySegment;
// Segment analysis
@override Map<String, double>? get revenueBySegment {
  final value = _revenueBySegment;
  if (value == null) return null;
  if (_revenueBySegment is EqualUnmodifiableMapView) return _revenueBySegment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _growthBySegment;
@override Map<String, double>? get growthBySegment {
  final value = _growthBySegment;
  if (value == null) return null;
  if (_growthBySegment is EqualUnmodifiableMapView) return _growthBySegment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, double>? _churnBySegment;
@override Map<String, double>? get churnBySegment {
  final value = _churnBySegment;
  if (value == null) return null;
  if (_churnBySegment is EqualUnmodifiableMapView) return _churnBySegment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Trend analysis
 final  List<RevenueMetricTrend>? _metricTrends;
// Trend analysis
@override List<RevenueMetricTrend>? get metricTrends {
  final value = _metricTrends;
  if (value == null) return null;
  if (_metricTrends is EqualUnmodifiableListView) return _metricTrends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<RevenueDriverAnalysis>? _driverAnalysis;
@override List<RevenueDriverAnalysis>? get driverAnalysis {
  final value = _driverAnalysis;
  if (value == null) return null;
  if (_driverAnalysis is EqualUnmodifiableListView) return _driverAnalysis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Insights
 final  List<RevenueInsight>? _insights;
// Insights
@override List<RevenueInsight>? get insights {
  final value = _insights;
  if (value == null) return null;
  if (_insights is EqualUnmodifiableListView) return _insights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<RevenueRecommendation>? _recommendations;
@override List<RevenueRecommendation>? get recommendations {
  final value = _recommendations;
  if (value == null) return null;
  if (_recommendations is EqualUnmodifiableListView) return _recommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? summary;
 final  Map<String, dynamic>? _analysisData;
@override Map<String, dynamic>? get analysisData {
  final value = _analysisData;
  if (value == null) return null;
  if (_analysisData is EqualUnmodifiableMapView) return _analysisData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of RevenueAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueAnalysisCopyWith<_RevenueAnalysis> get copyWith => __$RevenueAnalysisCopyWithImpl<_RevenueAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueAnalysis&&(identical(other.analysisDate, analysisDate) || other.analysisDate == analysisDate)&&(identical(other.period, period) || other.period == period)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.revenueGrowth, revenueGrowth) || other.revenueGrowth == revenueGrowth)&&(identical(other.revenueGrowthRate, revenueGrowthRate) || other.revenueGrowthRate == revenueGrowthRate)&&(identical(other.collectionRate, collectionRate) || other.collectionRate == collectionRate)&&(identical(other.churnRate, churnRate) || other.churnRate == churnRate)&&(identical(other.expansionRate, expansionRate) || other.expansionRate == expansionRate)&&(identical(other.netRevenueRetention, netRevenueRetention) || other.netRevenueRetention == netRevenueRetention)&&(identical(other.grossRevenueRetention, grossRevenueRetention) || other.grossRevenueRetention == grossRevenueRetention)&&(identical(other.monthlyRecurringRevenue, monthlyRecurringRevenue) || other.monthlyRecurringRevenue == monthlyRecurringRevenue)&&(identical(other.annualRecurringRevenue, annualRecurringRevenue) || other.annualRecurringRevenue == annualRecurringRevenue)&&(identical(other.averageRevenuePerUser, averageRevenuePerUser) || other.averageRevenuePerUser == averageRevenuePerUser)&&(identical(other.lifetimeValue, lifetimeValue) || other.lifetimeValue == lifetimeValue)&&(identical(other.customerAcquisitionCost, customerAcquisitionCost) || other.customerAcquisitionCost == customerAcquisitionCost)&&const DeepCollectionEquality().equals(other._revenueBySegment, _revenueBySegment)&&const DeepCollectionEquality().equals(other._growthBySegment, _growthBySegment)&&const DeepCollectionEquality().equals(other._churnBySegment, _churnBySegment)&&const DeepCollectionEquality().equals(other._metricTrends, _metricTrends)&&const DeepCollectionEquality().equals(other._driverAnalysis, _driverAnalysis)&&const DeepCollectionEquality().equals(other._insights, _insights)&&const DeepCollectionEquality().equals(other._recommendations, _recommendations)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._analysisData, _analysisData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,analysisDate,period,totalRevenue,revenueGrowth,revenueGrowthRate,collectionRate,churnRate,expansionRate,netRevenueRetention,grossRevenueRetention,monthlyRecurringRevenue,annualRecurringRevenue,averageRevenuePerUser,lifetimeValue,customerAcquisitionCost,const DeepCollectionEquality().hash(_revenueBySegment),const DeepCollectionEquality().hash(_growthBySegment),const DeepCollectionEquality().hash(_churnBySegment),const DeepCollectionEquality().hash(_metricTrends),const DeepCollectionEquality().hash(_driverAnalysis),const DeepCollectionEquality().hash(_insights),const DeepCollectionEquality().hash(_recommendations),summary,const DeepCollectionEquality().hash(_analysisData)]);

@override
String toString() {
  return 'RevenueAnalysis(analysisDate: $analysisDate, period: $period, totalRevenue: $totalRevenue, revenueGrowth: $revenueGrowth, revenueGrowthRate: $revenueGrowthRate, collectionRate: $collectionRate, churnRate: $churnRate, expansionRate: $expansionRate, netRevenueRetention: $netRevenueRetention, grossRevenueRetention: $grossRevenueRetention, monthlyRecurringRevenue: $monthlyRecurringRevenue, annualRecurringRevenue: $annualRecurringRevenue, averageRevenuePerUser: $averageRevenuePerUser, lifetimeValue: $lifetimeValue, customerAcquisitionCost: $customerAcquisitionCost, revenueBySegment: $revenueBySegment, growthBySegment: $growthBySegment, churnBySegment: $churnBySegment, metricTrends: $metricTrends, driverAnalysis: $driverAnalysis, insights: $insights, recommendations: $recommendations, summary: $summary, analysisData: $analysisData)';
}


}

/// @nodoc
abstract mixin class _$RevenueAnalysisCopyWith<$Res> implements $RevenueAnalysisCopyWith<$Res> {
  factory _$RevenueAnalysisCopyWith(_RevenueAnalysis value, $Res Function(_RevenueAnalysis) _then) = __$RevenueAnalysisCopyWithImpl;
@override @useResult
$Res call({
 DateTime analysisDate, AnalysisPeriod period, double totalRevenue, double revenueGrowth, double revenueGrowthRate, double collectionRate, double churnRate, double expansionRate, double netRevenueRetention, double grossRevenueRetention, double monthlyRecurringRevenue, double annualRecurringRevenue, double averageRevenuePerUser, double lifetimeValue, double customerAcquisitionCost, Map<String, double>? revenueBySegment, Map<String, double>? growthBySegment, Map<String, double>? churnBySegment, List<RevenueMetricTrend>? metricTrends, List<RevenueDriverAnalysis>? driverAnalysis, List<RevenueInsight>? insights, List<RevenueRecommendation>? recommendations, String? summary, Map<String, dynamic>? analysisData
});




}
/// @nodoc
class __$RevenueAnalysisCopyWithImpl<$Res>
    implements _$RevenueAnalysisCopyWith<$Res> {
  __$RevenueAnalysisCopyWithImpl(this._self, this._then);

  final _RevenueAnalysis _self;
  final $Res Function(_RevenueAnalysis) _then;

/// Create a copy of RevenueAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? analysisDate = null,Object? period = null,Object? totalRevenue = null,Object? revenueGrowth = null,Object? revenueGrowthRate = null,Object? collectionRate = null,Object? churnRate = null,Object? expansionRate = null,Object? netRevenueRetention = null,Object? grossRevenueRetention = null,Object? monthlyRecurringRevenue = null,Object? annualRecurringRevenue = null,Object? averageRevenuePerUser = null,Object? lifetimeValue = null,Object? customerAcquisitionCost = null,Object? revenueBySegment = freezed,Object? growthBySegment = freezed,Object? churnBySegment = freezed,Object? metricTrends = freezed,Object? driverAnalysis = freezed,Object? insights = freezed,Object? recommendations = freezed,Object? summary = freezed,Object? analysisData = freezed,}) {
  return _then(_RevenueAnalysis(
analysisDate: null == analysisDate ? _self.analysisDate : analysisDate // ignore: cast_nullable_to_non_nullable
as DateTime,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as AnalysisPeriod,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueGrowth: null == revenueGrowth ? _self.revenueGrowth : revenueGrowth // ignore: cast_nullable_to_non_nullable
as double,revenueGrowthRate: null == revenueGrowthRate ? _self.revenueGrowthRate : revenueGrowthRate // ignore: cast_nullable_to_non_nullable
as double,collectionRate: null == collectionRate ? _self.collectionRate : collectionRate // ignore: cast_nullable_to_non_nullable
as double,churnRate: null == churnRate ? _self.churnRate : churnRate // ignore: cast_nullable_to_non_nullable
as double,expansionRate: null == expansionRate ? _self.expansionRate : expansionRate // ignore: cast_nullable_to_non_nullable
as double,netRevenueRetention: null == netRevenueRetention ? _self.netRevenueRetention : netRevenueRetention // ignore: cast_nullable_to_non_nullable
as double,grossRevenueRetention: null == grossRevenueRetention ? _self.grossRevenueRetention : grossRevenueRetention // ignore: cast_nullable_to_non_nullable
as double,monthlyRecurringRevenue: null == monthlyRecurringRevenue ? _self.monthlyRecurringRevenue : monthlyRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,annualRecurringRevenue: null == annualRecurringRevenue ? _self.annualRecurringRevenue : annualRecurringRevenue // ignore: cast_nullable_to_non_nullable
as double,averageRevenuePerUser: null == averageRevenuePerUser ? _self.averageRevenuePerUser : averageRevenuePerUser // ignore: cast_nullable_to_non_nullable
as double,lifetimeValue: null == lifetimeValue ? _self.lifetimeValue : lifetimeValue // ignore: cast_nullable_to_non_nullable
as double,customerAcquisitionCost: null == customerAcquisitionCost ? _self.customerAcquisitionCost : customerAcquisitionCost // ignore: cast_nullable_to_non_nullable
as double,revenueBySegment: freezed == revenueBySegment ? _self._revenueBySegment : revenueBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,growthBySegment: freezed == growthBySegment ? _self._growthBySegment : growthBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,churnBySegment: freezed == churnBySegment ? _self._churnBySegment : churnBySegment // ignore: cast_nullable_to_non_nullable
as Map<String, double>?,metricTrends: freezed == metricTrends ? _self._metricTrends : metricTrends // ignore: cast_nullable_to_non_nullable
as List<RevenueMetricTrend>?,driverAnalysis: freezed == driverAnalysis ? _self._driverAnalysis : driverAnalysis // ignore: cast_nullable_to_non_nullable
as List<RevenueDriverAnalysis>?,insights: freezed == insights ? _self._insights : insights // ignore: cast_nullable_to_non_nullable
as List<RevenueInsight>?,recommendations: freezed == recommendations ? _self._recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<RevenueRecommendation>?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,analysisData: freezed == analysisData ? _self._analysisData : analysisData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$RevenueMetricTrend {

 String get metricName; String get metricDisplayName; String get metricUnit; List<MetricDataPoint> get dataPoints; double get currentValue; double get previousValue; double get changeAmount; double get changePercentage; TrendDirection get direction; String? get insight;
/// Create a copy of RevenueMetricTrend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueMetricTrendCopyWith<RevenueMetricTrend> get copyWith => _$RevenueMetricTrendCopyWithImpl<RevenueMetricTrend>(this as RevenueMetricTrend, _$identity);

  /// Serializes this RevenueMetricTrend to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueMetricTrend&&(identical(other.metricName, metricName) || other.metricName == metricName)&&(identical(other.metricDisplayName, metricDisplayName) || other.metricDisplayName == metricDisplayName)&&(identical(other.metricUnit, metricUnit) || other.metricUnit == metricUnit)&&const DeepCollectionEquality().equals(other.dataPoints, dataPoints)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.changeAmount, changeAmount) || other.changeAmount == changeAmount)&&(identical(other.changePercentage, changePercentage) || other.changePercentage == changePercentage)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.insight, insight) || other.insight == insight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricName,metricDisplayName,metricUnit,const DeepCollectionEquality().hash(dataPoints),currentValue,previousValue,changeAmount,changePercentage,direction,insight);

@override
String toString() {
  return 'RevenueMetricTrend(metricName: $metricName, metricDisplayName: $metricDisplayName, metricUnit: $metricUnit, dataPoints: $dataPoints, currentValue: $currentValue, previousValue: $previousValue, changeAmount: $changeAmount, changePercentage: $changePercentage, direction: $direction, insight: $insight)';
}


}

/// @nodoc
abstract mixin class $RevenueMetricTrendCopyWith<$Res>  {
  factory $RevenueMetricTrendCopyWith(RevenueMetricTrend value, $Res Function(RevenueMetricTrend) _then) = _$RevenueMetricTrendCopyWithImpl;
@useResult
$Res call({
 String metricName, String metricDisplayName, String metricUnit, List<MetricDataPoint> dataPoints, double currentValue, double previousValue, double changeAmount, double changePercentage, TrendDirection direction, String? insight
});




}
/// @nodoc
class _$RevenueMetricTrendCopyWithImpl<$Res>
    implements $RevenueMetricTrendCopyWith<$Res> {
  _$RevenueMetricTrendCopyWithImpl(this._self, this._then);

  final RevenueMetricTrend _self;
  final $Res Function(RevenueMetricTrend) _then;

/// Create a copy of RevenueMetricTrend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricName = null,Object? metricDisplayName = null,Object? metricUnit = null,Object? dataPoints = null,Object? currentValue = null,Object? previousValue = null,Object? changeAmount = null,Object? changePercentage = null,Object? direction = null,Object? insight = freezed,}) {
  return _then(_self.copyWith(
metricName: null == metricName ? _self.metricName : metricName // ignore: cast_nullable_to_non_nullable
as String,metricDisplayName: null == metricDisplayName ? _self.metricDisplayName : metricDisplayName // ignore: cast_nullable_to_non_nullable
as String,metricUnit: null == metricUnit ? _self.metricUnit : metricUnit // ignore: cast_nullable_to_non_nullable
as String,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<MetricDataPoint>,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double,changeAmount: null == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as double,changePercentage: null == changePercentage ? _self.changePercentage : changePercentage // ignore: cast_nullable_to_non_nullable
as double,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TrendDirection,insight: freezed == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueMetricTrend].
extension RevenueMetricTrendPatterns on RevenueMetricTrend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueMetricTrend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueMetricTrend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueMetricTrend value)  $default,){
final _that = this;
switch (_that) {
case _RevenueMetricTrend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueMetricTrend value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueMetricTrend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String metricName,  String metricDisplayName,  String metricUnit,  List<MetricDataPoint> dataPoints,  double currentValue,  double previousValue,  double changeAmount,  double changePercentage,  TrendDirection direction,  String? insight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueMetricTrend() when $default != null:
return $default(_that.metricName,_that.metricDisplayName,_that.metricUnit,_that.dataPoints,_that.currentValue,_that.previousValue,_that.changeAmount,_that.changePercentage,_that.direction,_that.insight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String metricName,  String metricDisplayName,  String metricUnit,  List<MetricDataPoint> dataPoints,  double currentValue,  double previousValue,  double changeAmount,  double changePercentage,  TrendDirection direction,  String? insight)  $default,) {final _that = this;
switch (_that) {
case _RevenueMetricTrend():
return $default(_that.metricName,_that.metricDisplayName,_that.metricUnit,_that.dataPoints,_that.currentValue,_that.previousValue,_that.changeAmount,_that.changePercentage,_that.direction,_that.insight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String metricName,  String metricDisplayName,  String metricUnit,  List<MetricDataPoint> dataPoints,  double currentValue,  double previousValue,  double changeAmount,  double changePercentage,  TrendDirection direction,  String? insight)?  $default,) {final _that = this;
switch (_that) {
case _RevenueMetricTrend() when $default != null:
return $default(_that.metricName,_that.metricDisplayName,_that.metricUnit,_that.dataPoints,_that.currentValue,_that.previousValue,_that.changeAmount,_that.changePercentage,_that.direction,_that.insight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueMetricTrend implements RevenueMetricTrend {
  const _RevenueMetricTrend({required this.metricName, required this.metricDisplayName, required this.metricUnit, required final  List<MetricDataPoint> dataPoints, required this.currentValue, required this.previousValue, required this.changeAmount, required this.changePercentage, required this.direction, this.insight}): _dataPoints = dataPoints;
  factory _RevenueMetricTrend.fromJson(Map<String, dynamic> json) => _$RevenueMetricTrendFromJson(json);

@override final  String metricName;
@override final  String metricDisplayName;
@override final  String metricUnit;
 final  List<MetricDataPoint> _dataPoints;
@override List<MetricDataPoint> get dataPoints {
  if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dataPoints);
}

@override final  double currentValue;
@override final  double previousValue;
@override final  double changeAmount;
@override final  double changePercentage;
@override final  TrendDirection direction;
@override final  String? insight;

/// Create a copy of RevenueMetricTrend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueMetricTrendCopyWith<_RevenueMetricTrend> get copyWith => __$RevenueMetricTrendCopyWithImpl<_RevenueMetricTrend>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueMetricTrendToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueMetricTrend&&(identical(other.metricName, metricName) || other.metricName == metricName)&&(identical(other.metricDisplayName, metricDisplayName) || other.metricDisplayName == metricDisplayName)&&(identical(other.metricUnit, metricUnit) || other.metricUnit == metricUnit)&&const DeepCollectionEquality().equals(other._dataPoints, _dataPoints)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.previousValue, previousValue) || other.previousValue == previousValue)&&(identical(other.changeAmount, changeAmount) || other.changeAmount == changeAmount)&&(identical(other.changePercentage, changePercentage) || other.changePercentage == changePercentage)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.insight, insight) || other.insight == insight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricName,metricDisplayName,metricUnit,const DeepCollectionEquality().hash(_dataPoints),currentValue,previousValue,changeAmount,changePercentage,direction,insight);

@override
String toString() {
  return 'RevenueMetricTrend(metricName: $metricName, metricDisplayName: $metricDisplayName, metricUnit: $metricUnit, dataPoints: $dataPoints, currentValue: $currentValue, previousValue: $previousValue, changeAmount: $changeAmount, changePercentage: $changePercentage, direction: $direction, insight: $insight)';
}


}

/// @nodoc
abstract mixin class _$RevenueMetricTrendCopyWith<$Res> implements $RevenueMetricTrendCopyWith<$Res> {
  factory _$RevenueMetricTrendCopyWith(_RevenueMetricTrend value, $Res Function(_RevenueMetricTrend) _then) = __$RevenueMetricTrendCopyWithImpl;
@override @useResult
$Res call({
 String metricName, String metricDisplayName, String metricUnit, List<MetricDataPoint> dataPoints, double currentValue, double previousValue, double changeAmount, double changePercentage, TrendDirection direction, String? insight
});




}
/// @nodoc
class __$RevenueMetricTrendCopyWithImpl<$Res>
    implements _$RevenueMetricTrendCopyWith<$Res> {
  __$RevenueMetricTrendCopyWithImpl(this._self, this._then);

  final _RevenueMetricTrend _self;
  final $Res Function(_RevenueMetricTrend) _then;

/// Create a copy of RevenueMetricTrend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricName = null,Object? metricDisplayName = null,Object? metricUnit = null,Object? dataPoints = null,Object? currentValue = null,Object? previousValue = null,Object? changeAmount = null,Object? changePercentage = null,Object? direction = null,Object? insight = freezed,}) {
  return _then(_RevenueMetricTrend(
metricName: null == metricName ? _self.metricName : metricName // ignore: cast_nullable_to_non_nullable
as String,metricDisplayName: null == metricDisplayName ? _self.metricDisplayName : metricDisplayName // ignore: cast_nullable_to_non_nullable
as String,metricUnit: null == metricUnit ? _self.metricUnit : metricUnit // ignore: cast_nullable_to_non_nullable
as String,dataPoints: null == dataPoints ? _self._dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<MetricDataPoint>,currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,previousValue: null == previousValue ? _self.previousValue : previousValue // ignore: cast_nullable_to_non_nullable
as double,changeAmount: null == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as double,changePercentage: null == changePercentage ? _self.changePercentage : changePercentage // ignore: cast_nullable_to_non_nullable
as double,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TrendDirection,insight: freezed == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MetricDataPoint {

 DateTime get date; double get value; double? get targetValue; double? get forecastValue;
/// Create a copy of MetricDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricDataPointCopyWith<MetricDataPoint> get copyWith => _$MetricDataPointCopyWithImpl<MetricDataPoint>(this as MetricDataPoint, _$identity);

  /// Serializes this MetricDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetricDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.forecastValue, forecastValue) || other.forecastValue == forecastValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,targetValue,forecastValue);

@override
String toString() {
  return 'MetricDataPoint(date: $date, value: $value, targetValue: $targetValue, forecastValue: $forecastValue)';
}


}

/// @nodoc
abstract mixin class $MetricDataPointCopyWith<$Res>  {
  factory $MetricDataPointCopyWith(MetricDataPoint value, $Res Function(MetricDataPoint) _then) = _$MetricDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double value, double? targetValue, double? forecastValue
});




}
/// @nodoc
class _$MetricDataPointCopyWithImpl<$Res>
    implements $MetricDataPointCopyWith<$Res> {
  _$MetricDataPointCopyWithImpl(this._self, this._then);

  final MetricDataPoint _self;
  final $Res Function(MetricDataPoint) _then;

/// Create a copy of MetricDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,Object? targetValue = freezed,Object? forecastValue = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,forecastValue: freezed == forecastValue ? _self.forecastValue : forecastValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetricDataPoint].
extension MetricDataPointPatterns on MetricDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetricDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetricDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetricDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _MetricDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetricDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _MetricDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double value,  double? targetValue,  double? forecastValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetricDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.targetValue,_that.forecastValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double value,  double? targetValue,  double? forecastValue)  $default,) {final _that = this;
switch (_that) {
case _MetricDataPoint():
return $default(_that.date,_that.value,_that.targetValue,_that.forecastValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double value,  double? targetValue,  double? forecastValue)?  $default,) {final _that = this;
switch (_that) {
case _MetricDataPoint() when $default != null:
return $default(_that.date,_that.value,_that.targetValue,_that.forecastValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetricDataPoint implements MetricDataPoint {
  const _MetricDataPoint({required this.date, required this.value, this.targetValue, this.forecastValue});
  factory _MetricDataPoint.fromJson(Map<String, dynamic> json) => _$MetricDataPointFromJson(json);

@override final  DateTime date;
@override final  double value;
@override final  double? targetValue;
@override final  double? forecastValue;

/// Create a copy of MetricDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetricDataPointCopyWith<_MetricDataPoint> get copyWith => __$MetricDataPointCopyWithImpl<_MetricDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetricDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetricDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.forecastValue, forecastValue) || other.forecastValue == forecastValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value,targetValue,forecastValue);

@override
String toString() {
  return 'MetricDataPoint(date: $date, value: $value, targetValue: $targetValue, forecastValue: $forecastValue)';
}


}

/// @nodoc
abstract mixin class _$MetricDataPointCopyWith<$Res> implements $MetricDataPointCopyWith<$Res> {
  factory _$MetricDataPointCopyWith(_MetricDataPoint value, $Res Function(_MetricDataPoint) _then) = __$MetricDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double value, double? targetValue, double? forecastValue
});




}
/// @nodoc
class __$MetricDataPointCopyWithImpl<$Res>
    implements _$MetricDataPointCopyWith<$Res> {
  __$MetricDataPointCopyWithImpl(this._self, this._then);

  final _MetricDataPoint _self;
  final $Res Function(_MetricDataPoint) _then;

/// Create a copy of MetricDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,Object? targetValue = freezed,Object? forecastValue = freezed,}) {
  return _then(_MetricDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,forecastValue: freezed == forecastValue ? _self.forecastValue : forecastValue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$RevenueDriverAnalysis {

 String get driverName; String get driverDisplayName; DriverType get type; double get impactScore; double get correlationCoefficient; List<DriverDataPoint> get dataPoints; String? get explanation; List<DriverRecommendation>? get recommendations;
/// Create a copy of RevenueDriverAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueDriverAnalysisCopyWith<RevenueDriverAnalysis> get copyWith => _$RevenueDriverAnalysisCopyWithImpl<RevenueDriverAnalysis>(this as RevenueDriverAnalysis, _$identity);

  /// Serializes this RevenueDriverAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueDriverAnalysis&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverDisplayName, driverDisplayName) || other.driverDisplayName == driverDisplayName)&&(identical(other.type, type) || other.type == type)&&(identical(other.impactScore, impactScore) || other.impactScore == impactScore)&&(identical(other.correlationCoefficient, correlationCoefficient) || other.correlationCoefficient == correlationCoefficient)&&const DeepCollectionEquality().equals(other.dataPoints, dataPoints)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&const DeepCollectionEquality().equals(other.recommendations, recommendations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverName,driverDisplayName,type,impactScore,correlationCoefficient,const DeepCollectionEquality().hash(dataPoints),explanation,const DeepCollectionEquality().hash(recommendations));

@override
String toString() {
  return 'RevenueDriverAnalysis(driverName: $driverName, driverDisplayName: $driverDisplayName, type: $type, impactScore: $impactScore, correlationCoefficient: $correlationCoefficient, dataPoints: $dataPoints, explanation: $explanation, recommendations: $recommendations)';
}


}

/// @nodoc
abstract mixin class $RevenueDriverAnalysisCopyWith<$Res>  {
  factory $RevenueDriverAnalysisCopyWith(RevenueDriverAnalysis value, $Res Function(RevenueDriverAnalysis) _then) = _$RevenueDriverAnalysisCopyWithImpl;
@useResult
$Res call({
 String driverName, String driverDisplayName, DriverType type, double impactScore, double correlationCoefficient, List<DriverDataPoint> dataPoints, String? explanation, List<DriverRecommendation>? recommendations
});




}
/// @nodoc
class _$RevenueDriverAnalysisCopyWithImpl<$Res>
    implements $RevenueDriverAnalysisCopyWith<$Res> {
  _$RevenueDriverAnalysisCopyWithImpl(this._self, this._then);

  final RevenueDriverAnalysis _self;
  final $Res Function(RevenueDriverAnalysis) _then;

/// Create a copy of RevenueDriverAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverName = null,Object? driverDisplayName = null,Object? type = null,Object? impactScore = null,Object? correlationCoefficient = null,Object? dataPoints = null,Object? explanation = freezed,Object? recommendations = freezed,}) {
  return _then(_self.copyWith(
driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverDisplayName: null == driverDisplayName ? _self.driverDisplayName : driverDisplayName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DriverType,impactScore: null == impactScore ? _self.impactScore : impactScore // ignore: cast_nullable_to_non_nullable
as double,correlationCoefficient: null == correlationCoefficient ? _self.correlationCoefficient : correlationCoefficient // ignore: cast_nullable_to_non_nullable
as double,dataPoints: null == dataPoints ? _self.dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<DriverDataPoint>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,recommendations: freezed == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<DriverRecommendation>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueDriverAnalysis].
extension RevenueDriverAnalysisPatterns on RevenueDriverAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueDriverAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueDriverAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueDriverAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _RevenueDriverAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueDriverAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueDriverAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverName,  String driverDisplayName,  DriverType type,  double impactScore,  double correlationCoefficient,  List<DriverDataPoint> dataPoints,  String? explanation,  List<DriverRecommendation>? recommendations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueDriverAnalysis() when $default != null:
return $default(_that.driverName,_that.driverDisplayName,_that.type,_that.impactScore,_that.correlationCoefficient,_that.dataPoints,_that.explanation,_that.recommendations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverName,  String driverDisplayName,  DriverType type,  double impactScore,  double correlationCoefficient,  List<DriverDataPoint> dataPoints,  String? explanation,  List<DriverRecommendation>? recommendations)  $default,) {final _that = this;
switch (_that) {
case _RevenueDriverAnalysis():
return $default(_that.driverName,_that.driverDisplayName,_that.type,_that.impactScore,_that.correlationCoefficient,_that.dataPoints,_that.explanation,_that.recommendations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverName,  String driverDisplayName,  DriverType type,  double impactScore,  double correlationCoefficient,  List<DriverDataPoint> dataPoints,  String? explanation,  List<DriverRecommendation>? recommendations)?  $default,) {final _that = this;
switch (_that) {
case _RevenueDriverAnalysis() when $default != null:
return $default(_that.driverName,_that.driverDisplayName,_that.type,_that.impactScore,_that.correlationCoefficient,_that.dataPoints,_that.explanation,_that.recommendations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueDriverAnalysis implements RevenueDriverAnalysis {
  const _RevenueDriverAnalysis({required this.driverName, required this.driverDisplayName, required this.type, required this.impactScore, required this.correlationCoefficient, required final  List<DriverDataPoint> dataPoints, this.explanation, final  List<DriverRecommendation>? recommendations}): _dataPoints = dataPoints,_recommendations = recommendations;
  factory _RevenueDriverAnalysis.fromJson(Map<String, dynamic> json) => _$RevenueDriverAnalysisFromJson(json);

@override final  String driverName;
@override final  String driverDisplayName;
@override final  DriverType type;
@override final  double impactScore;
@override final  double correlationCoefficient;
 final  List<DriverDataPoint> _dataPoints;
@override List<DriverDataPoint> get dataPoints {
  if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dataPoints);
}

@override final  String? explanation;
 final  List<DriverRecommendation>? _recommendations;
@override List<DriverRecommendation>? get recommendations {
  final value = _recommendations;
  if (value == null) return null;
  if (_recommendations is EqualUnmodifiableListView) return _recommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RevenueDriverAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueDriverAnalysisCopyWith<_RevenueDriverAnalysis> get copyWith => __$RevenueDriverAnalysisCopyWithImpl<_RevenueDriverAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueDriverAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueDriverAnalysis&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverDisplayName, driverDisplayName) || other.driverDisplayName == driverDisplayName)&&(identical(other.type, type) || other.type == type)&&(identical(other.impactScore, impactScore) || other.impactScore == impactScore)&&(identical(other.correlationCoefficient, correlationCoefficient) || other.correlationCoefficient == correlationCoefficient)&&const DeepCollectionEquality().equals(other._dataPoints, _dataPoints)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&const DeepCollectionEquality().equals(other._recommendations, _recommendations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverName,driverDisplayName,type,impactScore,correlationCoefficient,const DeepCollectionEquality().hash(_dataPoints),explanation,const DeepCollectionEquality().hash(_recommendations));

@override
String toString() {
  return 'RevenueDriverAnalysis(driverName: $driverName, driverDisplayName: $driverDisplayName, type: $type, impactScore: $impactScore, correlationCoefficient: $correlationCoefficient, dataPoints: $dataPoints, explanation: $explanation, recommendations: $recommendations)';
}


}

/// @nodoc
abstract mixin class _$RevenueDriverAnalysisCopyWith<$Res> implements $RevenueDriverAnalysisCopyWith<$Res> {
  factory _$RevenueDriverAnalysisCopyWith(_RevenueDriverAnalysis value, $Res Function(_RevenueDriverAnalysis) _then) = __$RevenueDriverAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String driverName, String driverDisplayName, DriverType type, double impactScore, double correlationCoefficient, List<DriverDataPoint> dataPoints, String? explanation, List<DriverRecommendation>? recommendations
});




}
/// @nodoc
class __$RevenueDriverAnalysisCopyWithImpl<$Res>
    implements _$RevenueDriverAnalysisCopyWith<$Res> {
  __$RevenueDriverAnalysisCopyWithImpl(this._self, this._then);

  final _RevenueDriverAnalysis _self;
  final $Res Function(_RevenueDriverAnalysis) _then;

/// Create a copy of RevenueDriverAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverName = null,Object? driverDisplayName = null,Object? type = null,Object? impactScore = null,Object? correlationCoefficient = null,Object? dataPoints = null,Object? explanation = freezed,Object? recommendations = freezed,}) {
  return _then(_RevenueDriverAnalysis(
driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverDisplayName: null == driverDisplayName ? _self.driverDisplayName : driverDisplayName // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DriverType,impactScore: null == impactScore ? _self.impactScore : impactScore // ignore: cast_nullable_to_non_nullable
as double,correlationCoefficient: null == correlationCoefficient ? _self.correlationCoefficient : correlationCoefficient // ignore: cast_nullable_to_non_nullable
as double,dataPoints: null == dataPoints ? _self._dataPoints : dataPoints // ignore: cast_nullable_to_non_nullable
as List<DriverDataPoint>,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,recommendations: freezed == recommendations ? _self._recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<DriverRecommendation>?,
  ));
}


}


/// @nodoc
mixin _$DriverDataPoint {

 DateTime get date; double get driverValue; double get revenueValue; double? get expectedRevenue;
/// Create a copy of DriverDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverDataPointCopyWith<DriverDataPoint> get copyWith => _$DriverDataPointCopyWithImpl<DriverDataPoint>(this as DriverDataPoint, _$identity);

  /// Serializes this DriverDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.driverValue, driverValue) || other.driverValue == driverValue)&&(identical(other.revenueValue, revenueValue) || other.revenueValue == revenueValue)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,driverValue,revenueValue,expectedRevenue);

@override
String toString() {
  return 'DriverDataPoint(date: $date, driverValue: $driverValue, revenueValue: $revenueValue, expectedRevenue: $expectedRevenue)';
}


}

/// @nodoc
abstract mixin class $DriverDataPointCopyWith<$Res>  {
  factory $DriverDataPointCopyWith(DriverDataPoint value, $Res Function(DriverDataPoint) _then) = _$DriverDataPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double driverValue, double revenueValue, double? expectedRevenue
});




}
/// @nodoc
class _$DriverDataPointCopyWithImpl<$Res>
    implements $DriverDataPointCopyWith<$Res> {
  _$DriverDataPointCopyWithImpl(this._self, this._then);

  final DriverDataPoint _self;
  final $Res Function(DriverDataPoint) _then;

/// Create a copy of DriverDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? driverValue = null,Object? revenueValue = null,Object? expectedRevenue = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,driverValue: null == driverValue ? _self.driverValue : driverValue // ignore: cast_nullable_to_non_nullable
as double,revenueValue: null == revenueValue ? _self.revenueValue : revenueValue // ignore: cast_nullable_to_non_nullable
as double,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverDataPoint].
extension DriverDataPointPatterns on DriverDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _DriverDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _DriverDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double driverValue,  double revenueValue,  double? expectedRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverDataPoint() when $default != null:
return $default(_that.date,_that.driverValue,_that.revenueValue,_that.expectedRevenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double driverValue,  double revenueValue,  double? expectedRevenue)  $default,) {final _that = this;
switch (_that) {
case _DriverDataPoint():
return $default(_that.date,_that.driverValue,_that.revenueValue,_that.expectedRevenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double driverValue,  double revenueValue,  double? expectedRevenue)?  $default,) {final _that = this;
switch (_that) {
case _DriverDataPoint() when $default != null:
return $default(_that.date,_that.driverValue,_that.revenueValue,_that.expectedRevenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverDataPoint implements DriverDataPoint {
  const _DriverDataPoint({required this.date, required this.driverValue, required this.revenueValue, this.expectedRevenue});
  factory _DriverDataPoint.fromJson(Map<String, dynamic> json) => _$DriverDataPointFromJson(json);

@override final  DateTime date;
@override final  double driverValue;
@override final  double revenueValue;
@override final  double? expectedRevenue;

/// Create a copy of DriverDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverDataPointCopyWith<_DriverDataPoint> get copyWith => __$DriverDataPointCopyWithImpl<_DriverDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.driverValue, driverValue) || other.driverValue == driverValue)&&(identical(other.revenueValue, revenueValue) || other.revenueValue == revenueValue)&&(identical(other.expectedRevenue, expectedRevenue) || other.expectedRevenue == expectedRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,driverValue,revenueValue,expectedRevenue);

@override
String toString() {
  return 'DriverDataPoint(date: $date, driverValue: $driverValue, revenueValue: $revenueValue, expectedRevenue: $expectedRevenue)';
}


}

/// @nodoc
abstract mixin class _$DriverDataPointCopyWith<$Res> implements $DriverDataPointCopyWith<$Res> {
  factory _$DriverDataPointCopyWith(_DriverDataPoint value, $Res Function(_DriverDataPoint) _then) = __$DriverDataPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double driverValue, double revenueValue, double? expectedRevenue
});




}
/// @nodoc
class __$DriverDataPointCopyWithImpl<$Res>
    implements _$DriverDataPointCopyWith<$Res> {
  __$DriverDataPointCopyWithImpl(this._self, this._then);

  final _DriverDataPoint _self;
  final $Res Function(_DriverDataPoint) _then;

/// Create a copy of DriverDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? driverValue = null,Object? revenueValue = null,Object? expectedRevenue = freezed,}) {
  return _then(_DriverDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,driverValue: null == driverValue ? _self.driverValue : driverValue // ignore: cast_nullable_to_non_nullable
as double,revenueValue: null == revenueValue ? _self.revenueValue : revenueValue // ignore: cast_nullable_to_non_nullable
as double,expectedRevenue: freezed == expectedRevenue ? _self.expectedRevenue : expectedRevenue // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$DriverRecommendation {

 String get action; String get description; Priority get priority; double get expectedImpact; List<String> get requiredResources; DateTime? get targetCompletionDate; String? get responsibleTeam;
/// Create a copy of DriverRecommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverRecommendationCopyWith<DriverRecommendation> get copyWith => _$DriverRecommendationCopyWithImpl<DriverRecommendation>(this as DriverRecommendation, _$identity);

  /// Serializes this DriverRecommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverRecommendation&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.expectedImpact, expectedImpact) || other.expectedImpact == expectedImpact)&&const DeepCollectionEquality().equals(other.requiredResources, requiredResources)&&(identical(other.targetCompletionDate, targetCompletionDate) || other.targetCompletionDate == targetCompletionDate)&&(identical(other.responsibleTeam, responsibleTeam) || other.responsibleTeam == responsibleTeam));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,description,priority,expectedImpact,const DeepCollectionEquality().hash(requiredResources),targetCompletionDate,responsibleTeam);

@override
String toString() {
  return 'DriverRecommendation(action: $action, description: $description, priority: $priority, expectedImpact: $expectedImpact, requiredResources: $requiredResources, targetCompletionDate: $targetCompletionDate, responsibleTeam: $responsibleTeam)';
}


}

/// @nodoc
abstract mixin class $DriverRecommendationCopyWith<$Res>  {
  factory $DriverRecommendationCopyWith(DriverRecommendation value, $Res Function(DriverRecommendation) _then) = _$DriverRecommendationCopyWithImpl;
@useResult
$Res call({
 String action, String description, Priority priority, double expectedImpact, List<String> requiredResources, DateTime? targetCompletionDate, String? responsibleTeam
});




}
/// @nodoc
class _$DriverRecommendationCopyWithImpl<$Res>
    implements $DriverRecommendationCopyWith<$Res> {
  _$DriverRecommendationCopyWithImpl(this._self, this._then);

  final DriverRecommendation _self;
  final $Res Function(DriverRecommendation) _then;

/// Create a copy of DriverRecommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? description = null,Object? priority = null,Object? expectedImpact = null,Object? requiredResources = null,Object? targetCompletionDate = freezed,Object? responsibleTeam = freezed,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,expectedImpact: null == expectedImpact ? _self.expectedImpact : expectedImpact // ignore: cast_nullable_to_non_nullable
as double,requiredResources: null == requiredResources ? _self.requiredResources : requiredResources // ignore: cast_nullable_to_non_nullable
as List<String>,targetCompletionDate: freezed == targetCompletionDate ? _self.targetCompletionDate : targetCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,responsibleTeam: freezed == responsibleTeam ? _self.responsibleTeam : responsibleTeam // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverRecommendation].
extension DriverRecommendationPatterns on DriverRecommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverRecommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverRecommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverRecommendation value)  $default,){
final _that = this;
switch (_that) {
case _DriverRecommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverRecommendation value)?  $default,){
final _that = this;
switch (_that) {
case _DriverRecommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String action,  String description,  Priority priority,  double expectedImpact,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverRecommendation() when $default != null:
return $default(_that.action,_that.description,_that.priority,_that.expectedImpact,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String action,  String description,  Priority priority,  double expectedImpact,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam)  $default,) {final _that = this;
switch (_that) {
case _DriverRecommendation():
return $default(_that.action,_that.description,_that.priority,_that.expectedImpact,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String action,  String description,  Priority priority,  double expectedImpact,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam)?  $default,) {final _that = this;
switch (_that) {
case _DriverRecommendation() when $default != null:
return $default(_that.action,_that.description,_that.priority,_that.expectedImpact,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverRecommendation implements DriverRecommendation {
  const _DriverRecommendation({required this.action, required this.description, required this.priority, required this.expectedImpact, required final  List<String> requiredResources, this.targetCompletionDate, this.responsibleTeam}): _requiredResources = requiredResources;
  factory _DriverRecommendation.fromJson(Map<String, dynamic> json) => _$DriverRecommendationFromJson(json);

@override final  String action;
@override final  String description;
@override final  Priority priority;
@override final  double expectedImpact;
 final  List<String> _requiredResources;
@override List<String> get requiredResources {
  if (_requiredResources is EqualUnmodifiableListView) return _requiredResources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredResources);
}

@override final  DateTime? targetCompletionDate;
@override final  String? responsibleTeam;

/// Create a copy of DriverRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverRecommendationCopyWith<_DriverRecommendation> get copyWith => __$DriverRecommendationCopyWithImpl<_DriverRecommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverRecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverRecommendation&&(identical(other.action, action) || other.action == action)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.expectedImpact, expectedImpact) || other.expectedImpact == expectedImpact)&&const DeepCollectionEquality().equals(other._requiredResources, _requiredResources)&&(identical(other.targetCompletionDate, targetCompletionDate) || other.targetCompletionDate == targetCompletionDate)&&(identical(other.responsibleTeam, responsibleTeam) || other.responsibleTeam == responsibleTeam));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,description,priority,expectedImpact,const DeepCollectionEquality().hash(_requiredResources),targetCompletionDate,responsibleTeam);

@override
String toString() {
  return 'DriverRecommendation(action: $action, description: $description, priority: $priority, expectedImpact: $expectedImpact, requiredResources: $requiredResources, targetCompletionDate: $targetCompletionDate, responsibleTeam: $responsibleTeam)';
}


}

/// @nodoc
abstract mixin class _$DriverRecommendationCopyWith<$Res> implements $DriverRecommendationCopyWith<$Res> {
  factory _$DriverRecommendationCopyWith(_DriverRecommendation value, $Res Function(_DriverRecommendation) _then) = __$DriverRecommendationCopyWithImpl;
@override @useResult
$Res call({
 String action, String description, Priority priority, double expectedImpact, List<String> requiredResources, DateTime? targetCompletionDate, String? responsibleTeam
});




}
/// @nodoc
class __$DriverRecommendationCopyWithImpl<$Res>
    implements _$DriverRecommendationCopyWith<$Res> {
  __$DriverRecommendationCopyWithImpl(this._self, this._then);

  final _DriverRecommendation _self;
  final $Res Function(_DriverRecommendation) _then;

/// Create a copy of DriverRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? description = null,Object? priority = null,Object? expectedImpact = null,Object? requiredResources = null,Object? targetCompletionDate = freezed,Object? responsibleTeam = freezed,}) {
  return _then(_DriverRecommendation(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,expectedImpact: null == expectedImpact ? _self.expectedImpact : expectedImpact // ignore: cast_nullable_to_non_nullable
as double,requiredResources: null == requiredResources ? _self._requiredResources : requiredResources // ignore: cast_nullable_to_non_nullable
as List<String>,targetCompletionDate: freezed == targetCompletionDate ? _self.targetCompletionDate : targetCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,responsibleTeam: freezed == responsibleTeam ? _self.responsibleTeam : responsibleTeam // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RevenueInsight {

 String get id; String get title; String get description; InsightType get type; InsightSeverity get severity; DateTime get detectedAt; double get confidenceScore; List<String>? get affectedSegments; List<String>? get contributingFactors; List<String>? get suggestedActions; Map<String, dynamic>? get insightData; DateTime? get acknowledgedAt; String? get acknowledgedBy; DateTime? get resolvedAt; String? get resolvedBy; String? get resolutionNotes;
/// Create a copy of RevenueInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueInsightCopyWith<RevenueInsight> get copyWith => _$RevenueInsightCopyWithImpl<RevenueInsight>(this as RevenueInsight, _$identity);

  /// Serializes this RevenueInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other.affectedSegments, affectedSegments)&&const DeepCollectionEquality().equals(other.contributingFactors, contributingFactors)&&const DeepCollectionEquality().equals(other.suggestedActions, suggestedActions)&&const DeepCollectionEquality().equals(other.insightData, insightData)&&(identical(other.acknowledgedAt, acknowledgedAt) || other.acknowledgedAt == acknowledgedAt)&&(identical(other.acknowledgedBy, acknowledgedBy) || other.acknowledgedBy == acknowledgedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,type,severity,detectedAt,confidenceScore,const DeepCollectionEquality().hash(affectedSegments),const DeepCollectionEquality().hash(contributingFactors),const DeepCollectionEquality().hash(suggestedActions),const DeepCollectionEquality().hash(insightData),acknowledgedAt,acknowledgedBy,resolvedAt,resolvedBy,resolutionNotes);

@override
String toString() {
  return 'RevenueInsight(id: $id, title: $title, description: $description, type: $type, severity: $severity, detectedAt: $detectedAt, confidenceScore: $confidenceScore, affectedSegments: $affectedSegments, contributingFactors: $contributingFactors, suggestedActions: $suggestedActions, insightData: $insightData, acknowledgedAt: $acknowledgedAt, acknowledgedBy: $acknowledgedBy, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes)';
}


}

/// @nodoc
abstract mixin class $RevenueInsightCopyWith<$Res>  {
  factory $RevenueInsightCopyWith(RevenueInsight value, $Res Function(RevenueInsight) _then) = _$RevenueInsightCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, InsightType type, InsightSeverity severity, DateTime detectedAt, double confidenceScore, List<String>? affectedSegments, List<String>? contributingFactors, List<String>? suggestedActions, Map<String, dynamic>? insightData, DateTime? acknowledgedAt, String? acknowledgedBy, DateTime? resolvedAt, String? resolvedBy, String? resolutionNotes
});




}
/// @nodoc
class _$RevenueInsightCopyWithImpl<$Res>
    implements $RevenueInsightCopyWith<$Res> {
  _$RevenueInsightCopyWithImpl(this._self, this._then);

  final RevenueInsight _self;
  final $Res Function(RevenueInsight) _then;

/// Create a copy of RevenueInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? type = null,Object? severity = null,Object? detectedAt = null,Object? confidenceScore = null,Object? affectedSegments = freezed,Object? contributingFactors = freezed,Object? suggestedActions = freezed,Object? insightData = freezed,Object? acknowledgedAt = freezed,Object? acknowledgedBy = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as InsightSeverity,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,affectedSegments: freezed == affectedSegments ? _self.affectedSegments : affectedSegments // ignore: cast_nullable_to_non_nullable
as List<String>?,contributingFactors: freezed == contributingFactors ? _self.contributingFactors : contributingFactors // ignore: cast_nullable_to_non_nullable
as List<String>?,suggestedActions: freezed == suggestedActions ? _self.suggestedActions : suggestedActions // ignore: cast_nullable_to_non_nullable
as List<String>?,insightData: freezed == insightData ? _self.insightData : insightData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,acknowledgedAt: freezed == acknowledgedAt ? _self.acknowledgedAt : acknowledgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgedBy: freezed == acknowledgedBy ? _self.acknowledgedBy : acknowledgedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueInsight].
extension RevenueInsightPatterns on RevenueInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueInsight value)  $default,){
final _that = this;
switch (_that) {
case _RevenueInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueInsight value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  InsightType type,  InsightSeverity severity,  DateTime detectedAt,  double confidenceScore,  List<String>? affectedSegments,  List<String>? contributingFactors,  List<String>? suggestedActions,  Map<String, dynamic>? insightData,  DateTime? acknowledgedAt,  String? acknowledgedBy,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueInsight() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.severity,_that.detectedAt,_that.confidenceScore,_that.affectedSegments,_that.contributingFactors,_that.suggestedActions,_that.insightData,_that.acknowledgedAt,_that.acknowledgedBy,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  InsightType type,  InsightSeverity severity,  DateTime detectedAt,  double confidenceScore,  List<String>? affectedSegments,  List<String>? contributingFactors,  List<String>? suggestedActions,  Map<String, dynamic>? insightData,  DateTime? acknowledgedAt,  String? acknowledgedBy,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes)  $default,) {final _that = this;
switch (_that) {
case _RevenueInsight():
return $default(_that.id,_that.title,_that.description,_that.type,_that.severity,_that.detectedAt,_that.confidenceScore,_that.affectedSegments,_that.contributingFactors,_that.suggestedActions,_that.insightData,_that.acknowledgedAt,_that.acknowledgedBy,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  InsightType type,  InsightSeverity severity,  DateTime detectedAt,  double confidenceScore,  List<String>? affectedSegments,  List<String>? contributingFactors,  List<String>? suggestedActions,  Map<String, dynamic>? insightData,  DateTime? acknowledgedAt,  String? acknowledgedBy,  DateTime? resolvedAt,  String? resolvedBy,  String? resolutionNotes)?  $default,) {final _that = this;
switch (_that) {
case _RevenueInsight() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.type,_that.severity,_that.detectedAt,_that.confidenceScore,_that.affectedSegments,_that.contributingFactors,_that.suggestedActions,_that.insightData,_that.acknowledgedAt,_that.acknowledgedBy,_that.resolvedAt,_that.resolvedBy,_that.resolutionNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueInsight implements RevenueInsight {
  const _RevenueInsight({required this.id, required this.title, required this.description, required this.type, required this.severity, required this.detectedAt, required this.confidenceScore, final  List<String>? affectedSegments, final  List<String>? contributingFactors, final  List<String>? suggestedActions, final  Map<String, dynamic>? insightData, this.acknowledgedAt, this.acknowledgedBy, this.resolvedAt, this.resolvedBy, this.resolutionNotes}): _affectedSegments = affectedSegments,_contributingFactors = contributingFactors,_suggestedActions = suggestedActions,_insightData = insightData;
  factory _RevenueInsight.fromJson(Map<String, dynamic> json) => _$RevenueInsightFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  InsightType type;
@override final  InsightSeverity severity;
@override final  DateTime detectedAt;
@override final  double confidenceScore;
 final  List<String>? _affectedSegments;
@override List<String>? get affectedSegments {
  final value = _affectedSegments;
  if (value == null) return null;
  if (_affectedSegments is EqualUnmodifiableListView) return _affectedSegments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _contributingFactors;
@override List<String>? get contributingFactors {
  final value = _contributingFactors;
  if (value == null) return null;
  if (_contributingFactors is EqualUnmodifiableListView) return _contributingFactors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _suggestedActions;
@override List<String>? get suggestedActions {
  final value = _suggestedActions;
  if (value == null) return null;
  if (_suggestedActions is EqualUnmodifiableListView) return _suggestedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _insightData;
@override Map<String, dynamic>? get insightData {
  final value = _insightData;
  if (value == null) return null;
  if (_insightData is EqualUnmodifiableMapView) return _insightData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? acknowledgedAt;
@override final  String? acknowledgedBy;
@override final  DateTime? resolvedAt;
@override final  String? resolvedBy;
@override final  String? resolutionNotes;

/// Create a copy of RevenueInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueInsightCopyWith<_RevenueInsight> get copyWith => __$RevenueInsightCopyWithImpl<_RevenueInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueInsight&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other._affectedSegments, _affectedSegments)&&const DeepCollectionEquality().equals(other._contributingFactors, _contributingFactors)&&const DeepCollectionEquality().equals(other._suggestedActions, _suggestedActions)&&const DeepCollectionEquality().equals(other._insightData, _insightData)&&(identical(other.acknowledgedAt, acknowledgedAt) || other.acknowledgedAt == acknowledgedAt)&&(identical(other.acknowledgedBy, acknowledgedBy) || other.acknowledgedBy == acknowledgedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,type,severity,detectedAt,confidenceScore,const DeepCollectionEquality().hash(_affectedSegments),const DeepCollectionEquality().hash(_contributingFactors),const DeepCollectionEquality().hash(_suggestedActions),const DeepCollectionEquality().hash(_insightData),acknowledgedAt,acknowledgedBy,resolvedAt,resolvedBy,resolutionNotes);

@override
String toString() {
  return 'RevenueInsight(id: $id, title: $title, description: $description, type: $type, severity: $severity, detectedAt: $detectedAt, confidenceScore: $confidenceScore, affectedSegments: $affectedSegments, contributingFactors: $contributingFactors, suggestedActions: $suggestedActions, insightData: $insightData, acknowledgedAt: $acknowledgedAt, acknowledgedBy: $acknowledgedBy, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes)';
}


}

/// @nodoc
abstract mixin class _$RevenueInsightCopyWith<$Res> implements $RevenueInsightCopyWith<$Res> {
  factory _$RevenueInsightCopyWith(_RevenueInsight value, $Res Function(_RevenueInsight) _then) = __$RevenueInsightCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, InsightType type, InsightSeverity severity, DateTime detectedAt, double confidenceScore, List<String>? affectedSegments, List<String>? contributingFactors, List<String>? suggestedActions, Map<String, dynamic>? insightData, DateTime? acknowledgedAt, String? acknowledgedBy, DateTime? resolvedAt, String? resolvedBy, String? resolutionNotes
});




}
/// @nodoc
class __$RevenueInsightCopyWithImpl<$Res>
    implements _$RevenueInsightCopyWith<$Res> {
  __$RevenueInsightCopyWithImpl(this._self, this._then);

  final _RevenueInsight _self;
  final $Res Function(_RevenueInsight) _then;

/// Create a copy of RevenueInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? type = null,Object? severity = null,Object? detectedAt = null,Object? confidenceScore = null,Object? affectedSegments = freezed,Object? contributingFactors = freezed,Object? suggestedActions = freezed,Object? insightData = freezed,Object? acknowledgedAt = freezed,Object? acknowledgedBy = freezed,Object? resolvedAt = freezed,Object? resolvedBy = freezed,Object? resolutionNotes = freezed,}) {
  return _then(_RevenueInsight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as InsightSeverity,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,affectedSegments: freezed == affectedSegments ? _self._affectedSegments : affectedSegments // ignore: cast_nullable_to_non_nullable
as List<String>?,contributingFactors: freezed == contributingFactors ? _self._contributingFactors : contributingFactors // ignore: cast_nullable_to_non_nullable
as List<String>?,suggestedActions: freezed == suggestedActions ? _self._suggestedActions : suggestedActions // ignore: cast_nullable_to_non_nullable
as List<String>?,insightData: freezed == insightData ? _self._insightData : insightData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,acknowledgedAt: freezed == acknowledgedAt ? _self.acknowledgedAt : acknowledgedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acknowledgedBy: freezed == acknowledgedBy ? _self.acknowledgedBy : acknowledgedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RevenueRecommendation {

 String get id; String get title; String get description; RecommendationCategory get category; Priority get priority; double get expectedImpact; List<String> get implementationSteps; List<String> get requiredResources; DateTime? get targetCompletionDate; String? get responsibleTeam; String? get status; DateTime? get implementedAt; String? get implementedBy; double? get actualImpact; String? get implementationNotes;
/// Create a copy of RevenueRecommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueRecommendationCopyWith<RevenueRecommendation> get copyWith => _$RevenueRecommendationCopyWithImpl<RevenueRecommendation>(this as RevenueRecommendation, _$identity);

  /// Serializes this RevenueRecommendation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.expectedImpact, expectedImpact) || other.expectedImpact == expectedImpact)&&const DeepCollectionEquality().equals(other.implementationSteps, implementationSteps)&&const DeepCollectionEquality().equals(other.requiredResources, requiredResources)&&(identical(other.targetCompletionDate, targetCompletionDate) || other.targetCompletionDate == targetCompletionDate)&&(identical(other.responsibleTeam, responsibleTeam) || other.responsibleTeam == responsibleTeam)&&(identical(other.status, status) || other.status == status)&&(identical(other.implementedAt, implementedAt) || other.implementedAt == implementedAt)&&(identical(other.implementedBy, implementedBy) || other.implementedBy == implementedBy)&&(identical(other.actualImpact, actualImpact) || other.actualImpact == actualImpact)&&(identical(other.implementationNotes, implementationNotes) || other.implementationNotes == implementationNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,priority,expectedImpact,const DeepCollectionEquality().hash(implementationSteps),const DeepCollectionEquality().hash(requiredResources),targetCompletionDate,responsibleTeam,status,implementedAt,implementedBy,actualImpact,implementationNotes);

@override
String toString() {
  return 'RevenueRecommendation(id: $id, title: $title, description: $description, category: $category, priority: $priority, expectedImpact: $expectedImpact, implementationSteps: $implementationSteps, requiredResources: $requiredResources, targetCompletionDate: $targetCompletionDate, responsibleTeam: $responsibleTeam, status: $status, implementedAt: $implementedAt, implementedBy: $implementedBy, actualImpact: $actualImpact, implementationNotes: $implementationNotes)';
}


}

/// @nodoc
abstract mixin class $RevenueRecommendationCopyWith<$Res>  {
  factory $RevenueRecommendationCopyWith(RevenueRecommendation value, $Res Function(RevenueRecommendation) _then) = _$RevenueRecommendationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, RecommendationCategory category, Priority priority, double expectedImpact, List<String> implementationSteps, List<String> requiredResources, DateTime? targetCompletionDate, String? responsibleTeam, String? status, DateTime? implementedAt, String? implementedBy, double? actualImpact, String? implementationNotes
});




}
/// @nodoc
class _$RevenueRecommendationCopyWithImpl<$Res>
    implements $RevenueRecommendationCopyWith<$Res> {
  _$RevenueRecommendationCopyWithImpl(this._self, this._then);

  final RevenueRecommendation _self;
  final $Res Function(RevenueRecommendation) _then;

/// Create a copy of RevenueRecommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? category = null,Object? priority = null,Object? expectedImpact = null,Object? implementationSteps = null,Object? requiredResources = null,Object? targetCompletionDate = freezed,Object? responsibleTeam = freezed,Object? status = freezed,Object? implementedAt = freezed,Object? implementedBy = freezed,Object? actualImpact = freezed,Object? implementationNotes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecommendationCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,expectedImpact: null == expectedImpact ? _self.expectedImpact : expectedImpact // ignore: cast_nullable_to_non_nullable
as double,implementationSteps: null == implementationSteps ? _self.implementationSteps : implementationSteps // ignore: cast_nullable_to_non_nullable
as List<String>,requiredResources: null == requiredResources ? _self.requiredResources : requiredResources // ignore: cast_nullable_to_non_nullable
as List<String>,targetCompletionDate: freezed == targetCompletionDate ? _self.targetCompletionDate : targetCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,responsibleTeam: freezed == responsibleTeam ? _self.responsibleTeam : responsibleTeam // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,implementedAt: freezed == implementedAt ? _self.implementedAt : implementedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,implementedBy: freezed == implementedBy ? _self.implementedBy : implementedBy // ignore: cast_nullable_to_non_nullable
as String?,actualImpact: freezed == actualImpact ? _self.actualImpact : actualImpact // ignore: cast_nullable_to_non_nullable
as double?,implementationNotes: freezed == implementationNotes ? _self.implementationNotes : implementationNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueRecommendation].
extension RevenueRecommendationPatterns on RevenueRecommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueRecommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueRecommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueRecommendation value)  $default,){
final _that = this;
switch (_that) {
case _RevenueRecommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueRecommendation value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueRecommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  RecommendationCategory category,  Priority priority,  double expectedImpact,  List<String> implementationSteps,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam,  String? status,  DateTime? implementedAt,  String? implementedBy,  double? actualImpact,  String? implementationNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueRecommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.priority,_that.expectedImpact,_that.implementationSteps,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam,_that.status,_that.implementedAt,_that.implementedBy,_that.actualImpact,_that.implementationNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  RecommendationCategory category,  Priority priority,  double expectedImpact,  List<String> implementationSteps,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam,  String? status,  DateTime? implementedAt,  String? implementedBy,  double? actualImpact,  String? implementationNotes)  $default,) {final _that = this;
switch (_that) {
case _RevenueRecommendation():
return $default(_that.id,_that.title,_that.description,_that.category,_that.priority,_that.expectedImpact,_that.implementationSteps,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam,_that.status,_that.implementedAt,_that.implementedBy,_that.actualImpact,_that.implementationNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  RecommendationCategory category,  Priority priority,  double expectedImpact,  List<String> implementationSteps,  List<String> requiredResources,  DateTime? targetCompletionDate,  String? responsibleTeam,  String? status,  DateTime? implementedAt,  String? implementedBy,  double? actualImpact,  String? implementationNotes)?  $default,) {final _that = this;
switch (_that) {
case _RevenueRecommendation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.priority,_that.expectedImpact,_that.implementationSteps,_that.requiredResources,_that.targetCompletionDate,_that.responsibleTeam,_that.status,_that.implementedAt,_that.implementedBy,_that.actualImpact,_that.implementationNotes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueRecommendation implements RevenueRecommendation {
  const _RevenueRecommendation({required this.id, required this.title, required this.description, required this.category, required this.priority, required this.expectedImpact, required final  List<String> implementationSteps, required final  List<String> requiredResources, this.targetCompletionDate, this.responsibleTeam, this.status, this.implementedAt, this.implementedBy, this.actualImpact, this.implementationNotes}): _implementationSteps = implementationSteps,_requiredResources = requiredResources;
  factory _RevenueRecommendation.fromJson(Map<String, dynamic> json) => _$RevenueRecommendationFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  RecommendationCategory category;
@override final  Priority priority;
@override final  double expectedImpact;
 final  List<String> _implementationSteps;
@override List<String> get implementationSteps {
  if (_implementationSteps is EqualUnmodifiableListView) return _implementationSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_implementationSteps);
}

 final  List<String> _requiredResources;
@override List<String> get requiredResources {
  if (_requiredResources is EqualUnmodifiableListView) return _requiredResources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requiredResources);
}

@override final  DateTime? targetCompletionDate;
@override final  String? responsibleTeam;
@override final  String? status;
@override final  DateTime? implementedAt;
@override final  String? implementedBy;
@override final  double? actualImpact;
@override final  String? implementationNotes;

/// Create a copy of RevenueRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueRecommendationCopyWith<_RevenueRecommendation> get copyWith => __$RevenueRecommendationCopyWithImpl<_RevenueRecommendation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueRecommendationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueRecommendation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.expectedImpact, expectedImpact) || other.expectedImpact == expectedImpact)&&const DeepCollectionEquality().equals(other._implementationSteps, _implementationSteps)&&const DeepCollectionEquality().equals(other._requiredResources, _requiredResources)&&(identical(other.targetCompletionDate, targetCompletionDate) || other.targetCompletionDate == targetCompletionDate)&&(identical(other.responsibleTeam, responsibleTeam) || other.responsibleTeam == responsibleTeam)&&(identical(other.status, status) || other.status == status)&&(identical(other.implementedAt, implementedAt) || other.implementedAt == implementedAt)&&(identical(other.implementedBy, implementedBy) || other.implementedBy == implementedBy)&&(identical(other.actualImpact, actualImpact) || other.actualImpact == actualImpact)&&(identical(other.implementationNotes, implementationNotes) || other.implementationNotes == implementationNotes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,priority,expectedImpact,const DeepCollectionEquality().hash(_implementationSteps),const DeepCollectionEquality().hash(_requiredResources),targetCompletionDate,responsibleTeam,status,implementedAt,implementedBy,actualImpact,implementationNotes);

@override
String toString() {
  return 'RevenueRecommendation(id: $id, title: $title, description: $description, category: $category, priority: $priority, expectedImpact: $expectedImpact, implementationSteps: $implementationSteps, requiredResources: $requiredResources, targetCompletionDate: $targetCompletionDate, responsibleTeam: $responsibleTeam, status: $status, implementedAt: $implementedAt, implementedBy: $implementedBy, actualImpact: $actualImpact, implementationNotes: $implementationNotes)';
}


}

/// @nodoc
abstract mixin class _$RevenueRecommendationCopyWith<$Res> implements $RevenueRecommendationCopyWith<$Res> {
  factory _$RevenueRecommendationCopyWith(_RevenueRecommendation value, $Res Function(_RevenueRecommendation) _then) = __$RevenueRecommendationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, RecommendationCategory category, Priority priority, double expectedImpact, List<String> implementationSteps, List<String> requiredResources, DateTime? targetCompletionDate, String? responsibleTeam, String? status, DateTime? implementedAt, String? implementedBy, double? actualImpact, String? implementationNotes
});




}
/// @nodoc
class __$RevenueRecommendationCopyWithImpl<$Res>
    implements _$RevenueRecommendationCopyWith<$Res> {
  __$RevenueRecommendationCopyWithImpl(this._self, this._then);

  final _RevenueRecommendation _self;
  final $Res Function(_RevenueRecommendation) _then;

/// Create a copy of RevenueRecommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? category = null,Object? priority = null,Object? expectedImpact = null,Object? implementationSteps = null,Object? requiredResources = null,Object? targetCompletionDate = freezed,Object? responsibleTeam = freezed,Object? status = freezed,Object? implementedAt = freezed,Object? implementedBy = freezed,Object? actualImpact = freezed,Object? implementationNotes = freezed,}) {
  return _then(_RevenueRecommendation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as RecommendationCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority,expectedImpact: null == expectedImpact ? _self.expectedImpact : expectedImpact // ignore: cast_nullable_to_non_nullable
as double,implementationSteps: null == implementationSteps ? _self._implementationSteps : implementationSteps // ignore: cast_nullable_to_non_nullable
as List<String>,requiredResources: null == requiredResources ? _self._requiredResources : requiredResources // ignore: cast_nullable_to_non_nullable
as List<String>,targetCompletionDate: freezed == targetCompletionDate ? _self.targetCompletionDate : targetCompletionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,responsibleTeam: freezed == responsibleTeam ? _self.responsibleTeam : responsibleTeam // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,implementedAt: freezed == implementedAt ? _self.implementedAt : implementedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,implementedBy: freezed == implementedBy ? _self.implementedBy : implementedBy // ignore: cast_nullable_to_non_nullable
as String?,actualImpact: freezed == actualImpact ? _self.actualImpact : actualImpact // ignore: cast_nullable_to_non_nullable
as double?,implementationNotes: freezed == implementationNotes ? _self.implementationNotes : implementationNotes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportFilter {

 DateTime? get startDate; DateTime? get endDate; List<ReportType>? get types; List<ReportStatus>? get statuses; String? get generatedByAdminId; String? get searchQuery; String get sortBy; bool get sortDesc; int get page; int get limit;
/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFilterCopyWith<ReportFilter> get copyWith => _$ReportFilterCopyWithImpl<ReportFilter>(this as ReportFilter, _$identity);

  /// Serializes this ReportFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&(identical(other.generatedByAdminId, generatedByAdminId) || other.generatedByAdminId == generatedByAdminId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(statuses),generatedByAdminId,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReportFilter(startDate: $startDate, endDate: $endDate, types: $types, statuses: $statuses, generatedByAdminId: $generatedByAdminId, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ReportFilterCopyWith<$Res>  {
  factory $ReportFilterCopyWith(ReportFilter value, $Res Function(ReportFilter) _then) = _$ReportFilterCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReportType>? types, List<ReportStatus>? statuses, String? generatedByAdminId, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class _$ReportFilterCopyWithImpl<$Res>
    implements $ReportFilterCopyWith<$Res> {
  _$ReportFilterCopyWithImpl(this._self, this._then);

  final ReportFilter _self;
  final $Res Function(ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? types = freezed,Object? statuses = freezed,Object? generatedByAdminId = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_self.copyWith(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,types: freezed == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<ReportType>?,statuses: freezed == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReportStatus>?,generatedByAdminId: freezed == generatedByAdminId ? _self.generatedByAdminId : generatedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFilter].
extension ReportFilterPatterns on ReportFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReportFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReportType>? types,  List<ReportStatus>? statuses,  String? generatedByAdminId,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.types,_that.statuses,_that.generatedByAdminId,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startDate,  DateTime? endDate,  List<ReportType>? types,  List<ReportStatus>? statuses,  String? generatedByAdminId,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)  $default,) {final _that = this;
switch (_that) {
case _ReportFilter():
return $default(_that.startDate,_that.endDate,_that.types,_that.statuses,_that.generatedByAdminId,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startDate,  DateTime? endDate,  List<ReportType>? types,  List<ReportStatus>? statuses,  String? generatedByAdminId,  String? searchQuery,  String sortBy,  bool sortDesc,  int page,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _ReportFilter() when $default != null:
return $default(_that.startDate,_that.endDate,_that.types,_that.statuses,_that.generatedByAdminId,_that.searchQuery,_that.sortBy,_that.sortDesc,_that.page,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFilter implements ReportFilter {
  const _ReportFilter({this.startDate, this.endDate, final  List<ReportType>? types, final  List<ReportStatus>? statuses, this.generatedByAdminId, this.searchQuery, this.sortBy = 'generatedAt', this.sortDesc = true, this.page = 1, this.limit = 20}): _types = types,_statuses = statuses;
  factory _ReportFilter.fromJson(Map<String, dynamic> json) => _$ReportFilterFromJson(json);

@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<ReportType>? _types;
@override List<ReportType>? get types {
  final value = _types;
  if (value == null) return null;
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<ReportStatus>? _statuses;
@override List<ReportStatus>? get statuses {
  final value = _statuses;
  if (value == null) return null;
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? generatedByAdminId;
@override final  String? searchQuery;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortDesc;
@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFilterCopyWith<_ReportFilter> get copyWith => __$ReportFilterCopyWithImpl<_ReportFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFilter&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.generatedByAdminId, generatedByAdminId) || other.generatedByAdminId == generatedByAdminId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortDesc, sortDesc) || other.sortDesc == sortDesc)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_statuses),generatedByAdminId,searchQuery,sortBy,sortDesc,page,limit);

@override
String toString() {
  return 'ReportFilter(startDate: $startDate, endDate: $endDate, types: $types, statuses: $statuses, generatedByAdminId: $generatedByAdminId, searchQuery: $searchQuery, sortBy: $sortBy, sortDesc: $sortDesc, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$ReportFilterCopyWith<$Res> implements $ReportFilterCopyWith<$Res> {
  factory _$ReportFilterCopyWith(_ReportFilter value, $Res Function(_ReportFilter) _then) = __$ReportFilterCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<ReportType>? types, List<ReportStatus>? statuses, String? generatedByAdminId, String? searchQuery, String sortBy, bool sortDesc, int page, int limit
});




}
/// @nodoc
class __$ReportFilterCopyWithImpl<$Res>
    implements _$ReportFilterCopyWith<$Res> {
  __$ReportFilterCopyWithImpl(this._self, this._then);

  final _ReportFilter _self;
  final $Res Function(_ReportFilter) _then;

/// Create a copy of ReportFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? types = freezed,Object? statuses = freezed,Object? generatedByAdminId = freezed,Object? searchQuery = freezed,Object? sortBy = null,Object? sortDesc = null,Object? page = null,Object? limit = null,}) {
  return _then(_ReportFilter(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,types: freezed == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<ReportType>?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<ReportStatus>?,generatedByAdminId: freezed == generatedByAdminId ? _self.generatedByAdminId : generatedByAdminId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortDesc: null == sortDesc ? _self.sortDesc : sortDesc // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

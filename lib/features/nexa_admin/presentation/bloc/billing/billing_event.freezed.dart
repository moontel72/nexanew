// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_event.dart';

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadPlatformInvoices value)?  loadPlatformInvoices,TResult Function( LoadCompanyInvoices value)?  loadCompanyInvoices,TResult Function( GenerateInvoice value)?  generateInvoice,TResult Function( GenerateBulkInvoices value)?  generateBulkInvoices,TResult Function( ProcessPayment value)?  processPayment,TResult Function( ProcessPartialPayment value)?  processPartialPayment,TResult Function( ProcessBulkPayments value)?  processBulkPayments,TResult Function( ReconcilePayments value)?  reconcilePayments,TResult Function( AnalyzeReconciliation value)?  analyzeReconciliation,TResult Function( GenerateRevenueReport value)?  generateRevenueReport,TResult Function( GetFinancialDashboardData value)?  getFinancialDashboardData,TResult Function( ExportInvoices value)?  exportInvoices,TResult Function( ExportRevenueReport value)?  exportRevenueReport,TResult Function( UpdateInvoiceStatus value)?  updateInvoiceStatus,TResult Function( SendInvoiceNotification value)?  sendInvoiceNotification,TResult Function( CreateCreditNote value)?  createCreditNote,TResult Function( GetCreditNotes value)?  getCreditNotes,TResult Function( GetCompaniesWithOverdueInvoices value)?  getCompaniesWithOverdueInvoices,TResult Function( GetPlatformRevenueSummary value)?  getPlatformRevenueSummary,TResult Function( GetRevenueByCompany value)?  getRevenueByCompany,TResult Function( ResetBillingState value)?  resetBillingState,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadPlatformInvoices() when loadPlatformInvoices != null:
return loadPlatformInvoices(_that);case LoadCompanyInvoices() when loadCompanyInvoices != null:
return loadCompanyInvoices(_that);case GenerateInvoice() when generateInvoice != null:
return generateInvoice(_that);case GenerateBulkInvoices() when generateBulkInvoices != null:
return generateBulkInvoices(_that);case ProcessPayment() when processPayment != null:
return processPayment(_that);case ProcessPartialPayment() when processPartialPayment != null:
return processPartialPayment(_that);case ProcessBulkPayments() when processBulkPayments != null:
return processBulkPayments(_that);case ReconcilePayments() when reconcilePayments != null:
return reconcilePayments(_that);case AnalyzeReconciliation() when analyzeReconciliation != null:
return analyzeReconciliation(_that);case GenerateRevenueReport() when generateRevenueReport != null:
return generateRevenueReport(_that);case GetFinancialDashboardData() when getFinancialDashboardData != null:
return getFinancialDashboardData(_that);case ExportInvoices() when exportInvoices != null:
return exportInvoices(_that);case ExportRevenueReport() when exportRevenueReport != null:
return exportRevenueReport(_that);case UpdateInvoiceStatus() when updateInvoiceStatus != null:
return updateInvoiceStatus(_that);case SendInvoiceNotification() when sendInvoiceNotification != null:
return sendInvoiceNotification(_that);case CreateCreditNote() when createCreditNote != null:
return createCreditNote(_that);case GetCreditNotes() when getCreditNotes != null:
return getCreditNotes(_that);case GetCompaniesWithOverdueInvoices() when getCompaniesWithOverdueInvoices != null:
return getCompaniesWithOverdueInvoices(_that);case GetPlatformRevenueSummary() when getPlatformRevenueSummary != null:
return getPlatformRevenueSummary(_that);case GetRevenueByCompany() when getRevenueByCompany != null:
return getRevenueByCompany(_that);case ResetBillingState() when resetBillingState != null:
return resetBillingState(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadPlatformInvoices value)  loadPlatformInvoices,required TResult Function( LoadCompanyInvoices value)  loadCompanyInvoices,required TResult Function( GenerateInvoice value)  generateInvoice,required TResult Function( GenerateBulkInvoices value)  generateBulkInvoices,required TResult Function( ProcessPayment value)  processPayment,required TResult Function( ProcessPartialPayment value)  processPartialPayment,required TResult Function( ProcessBulkPayments value)  processBulkPayments,required TResult Function( ReconcilePayments value)  reconcilePayments,required TResult Function( AnalyzeReconciliation value)  analyzeReconciliation,required TResult Function( GenerateRevenueReport value)  generateRevenueReport,required TResult Function( GetFinancialDashboardData value)  getFinancialDashboardData,required TResult Function( ExportInvoices value)  exportInvoices,required TResult Function( ExportRevenueReport value)  exportRevenueReport,required TResult Function( UpdateInvoiceStatus value)  updateInvoiceStatus,required TResult Function( SendInvoiceNotification value)  sendInvoiceNotification,required TResult Function( CreateCreditNote value)  createCreditNote,required TResult Function( GetCreditNotes value)  getCreditNotes,required TResult Function( GetCompaniesWithOverdueInvoices value)  getCompaniesWithOverdueInvoices,required TResult Function( GetPlatformRevenueSummary value)  getPlatformRevenueSummary,required TResult Function( GetRevenueByCompany value)  getRevenueByCompany,required TResult Function( ResetBillingState value)  resetBillingState,}){
final _that = this;
switch (_that) {
case LoadPlatformInvoices():
return loadPlatformInvoices(_that);case LoadCompanyInvoices():
return loadCompanyInvoices(_that);case GenerateInvoice():
return generateInvoice(_that);case GenerateBulkInvoices():
return generateBulkInvoices(_that);case ProcessPayment():
return processPayment(_that);case ProcessPartialPayment():
return processPartialPayment(_that);case ProcessBulkPayments():
return processBulkPayments(_that);case ReconcilePayments():
return reconcilePayments(_that);case AnalyzeReconciliation():
return analyzeReconciliation(_that);case GenerateRevenueReport():
return generateRevenueReport(_that);case GetFinancialDashboardData():
return getFinancialDashboardData(_that);case ExportInvoices():
return exportInvoices(_that);case ExportRevenueReport():
return exportRevenueReport(_that);case UpdateInvoiceStatus():
return updateInvoiceStatus(_that);case SendInvoiceNotification():
return sendInvoiceNotification(_that);case CreateCreditNote():
return createCreditNote(_that);case GetCreditNotes():
return getCreditNotes(_that);case GetCompaniesWithOverdueInvoices():
return getCompaniesWithOverdueInvoices(_that);case GetPlatformRevenueSummary():
return getPlatformRevenueSummary(_that);case GetRevenueByCompany():
return getRevenueByCompany(_that);case ResetBillingState():
return resetBillingState(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadPlatformInvoices value)?  loadPlatformInvoices,TResult? Function( LoadCompanyInvoices value)?  loadCompanyInvoices,TResult? Function( GenerateInvoice value)?  generateInvoice,TResult? Function( GenerateBulkInvoices value)?  generateBulkInvoices,TResult? Function( ProcessPayment value)?  processPayment,TResult? Function( ProcessPartialPayment value)?  processPartialPayment,TResult? Function( ProcessBulkPayments value)?  processBulkPayments,TResult? Function( ReconcilePayments value)?  reconcilePayments,TResult? Function( AnalyzeReconciliation value)?  analyzeReconciliation,TResult? Function( GenerateRevenueReport value)?  generateRevenueReport,TResult? Function( GetFinancialDashboardData value)?  getFinancialDashboardData,TResult? Function( ExportInvoices value)?  exportInvoices,TResult? Function( ExportRevenueReport value)?  exportRevenueReport,TResult? Function( UpdateInvoiceStatus value)?  updateInvoiceStatus,TResult? Function( SendInvoiceNotification value)?  sendInvoiceNotification,TResult? Function( CreateCreditNote value)?  createCreditNote,TResult? Function( GetCreditNotes value)?  getCreditNotes,TResult? Function( GetCompaniesWithOverdueInvoices value)?  getCompaniesWithOverdueInvoices,TResult? Function( GetPlatformRevenueSummary value)?  getPlatformRevenueSummary,TResult? Function( GetRevenueByCompany value)?  getRevenueByCompany,TResult? Function( ResetBillingState value)?  resetBillingState,}){
final _that = this;
switch (_that) {
case LoadPlatformInvoices() when loadPlatformInvoices != null:
return loadPlatformInvoices(_that);case LoadCompanyInvoices() when loadCompanyInvoices != null:
return loadCompanyInvoices(_that);case GenerateInvoice() when generateInvoice != null:
return generateInvoice(_that);case GenerateBulkInvoices() when generateBulkInvoices != null:
return generateBulkInvoices(_that);case ProcessPayment() when processPayment != null:
return processPayment(_that);case ProcessPartialPayment() when processPartialPayment != null:
return processPartialPayment(_that);case ProcessBulkPayments() when processBulkPayments != null:
return processBulkPayments(_that);case ReconcilePayments() when reconcilePayments != null:
return reconcilePayments(_that);case AnalyzeReconciliation() when analyzeReconciliation != null:
return analyzeReconciliation(_that);case GenerateRevenueReport() when generateRevenueReport != null:
return generateRevenueReport(_that);case GetFinancialDashboardData() when getFinancialDashboardData != null:
return getFinancialDashboardData(_that);case ExportInvoices() when exportInvoices != null:
return exportInvoices(_that);case ExportRevenueReport() when exportRevenueReport != null:
return exportRevenueReport(_that);case UpdateInvoiceStatus() when updateInvoiceStatus != null:
return updateInvoiceStatus(_that);case SendInvoiceNotification() when sendInvoiceNotification != null:
return sendInvoiceNotification(_that);case CreateCreditNote() when createCreditNote != null:
return createCreditNote(_that);case GetCreditNotes() when getCreditNotes != null:
return getCreditNotes(_that);case GetCompaniesWithOverdueInvoices() when getCompaniesWithOverdueInvoices != null:
return getCompaniesWithOverdueInvoices(_that);case GetPlatformRevenueSummary() when getPlatformRevenueSummary != null:
return getPlatformRevenueSummary(_that);case GetRevenueByCompany() when getRevenueByCompany != null:
return getRevenueByCompany(_that);case ResetBillingState() when resetBillingState != null:
return resetBillingState(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String? searchQuery,  int page,  int limit)?  loadPlatformInvoices,TResult Function( String companyId,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  loadCompanyInvoices,TResult Function( String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  List<shared.InvoiceItem> items,  String? notes,  bool sendNotification)?  generateInvoice,TResult Function( List<GenerateInvoiceParams> paramsList)?  generateBulkInvoices,TResult Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)?  processPayment,TResult Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)?  processPartialPayment,TResult Function( List<ProcessPaymentParams> paramsList)?  processBulkPayments,TResult Function( DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  String? notes,  bool autoMatchTransactions,  double matchTolerance)?  reconcilePayments,TResult Function( String reconciliationId)?  analyzeReconciliation,TResult Function( ReportType type,  DateTime periodStart,  DateTime periodEnd,  String? reportName,  String? notes)?  generateRevenueReport,TResult Function( DateTime? startDate,  DateTime? endDate)?  getFinancialDashboardData,TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String format)?  exportInvoices,TResult Function( String reportId,  String format)?  exportRevenueReport,TResult Function( String invoiceId,  shared.InvoiceStatus status)?  updateInvoiceStatus,TResult Function( String invoiceId)?  sendInvoiceNotification,TResult Function( String invoiceId,  double amount,  CreditNoteReason reason,  String? notes)?  createCreditNote,TResult Function( DateTime? startDate,  DateTime? endDate,  String? companyId,  int page,  int limit)?  getCreditNotes,TResult Function()?  getCompaniesWithOverdueInvoices,TResult Function( DateTime? startDate,  DateTime? endDate)?  getPlatformRevenueSummary,TResult Function( DateTime? startDate,  DateTime? endDate)?  getRevenueByCompany,TResult Function()?  resetBillingState,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadPlatformInvoices() when loadPlatformInvoices != null:
return loadPlatformInvoices(_that.startDate,_that.endDate,_that.statuses,_that.searchQuery,_that.page,_that.limit);case LoadCompanyInvoices() when loadCompanyInvoices != null:
return loadCompanyInvoices(_that.companyId,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case GenerateInvoice() when generateInvoice != null:
return generateInvoice(_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.items,_that.notes,_that.sendNotification);case GenerateBulkInvoices() when generateBulkInvoices != null:
return generateBulkInvoices(_that.paramsList);case ProcessPayment() when processPayment != null:
return processPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessPartialPayment() when processPartialPayment != null:
return processPartialPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessBulkPayments() when processBulkPayments != null:
return processBulkPayments(_that.paramsList);case ReconcilePayments() when reconcilePayments != null:
return reconcilePayments(_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.notes,_that.autoMatchTransactions,_that.matchTolerance);case AnalyzeReconciliation() when analyzeReconciliation != null:
return analyzeReconciliation(_that.reconciliationId);case GenerateRevenueReport() when generateRevenueReport != null:
return generateRevenueReport(_that.type,_that.periodStart,_that.periodEnd,_that.reportName,_that.notes);case GetFinancialDashboardData() when getFinancialDashboardData != null:
return getFinancialDashboardData(_that.startDate,_that.endDate);case ExportInvoices() when exportInvoices != null:
return exportInvoices(_that.startDate,_that.endDate,_that.statuses,_that.format);case ExportRevenueReport() when exportRevenueReport != null:
return exportRevenueReport(_that.reportId,_that.format);case UpdateInvoiceStatus() when updateInvoiceStatus != null:
return updateInvoiceStatus(_that.invoiceId,_that.status);case SendInvoiceNotification() when sendInvoiceNotification != null:
return sendInvoiceNotification(_that.invoiceId);case CreateCreditNote() when createCreditNote != null:
return createCreditNote(_that.invoiceId,_that.amount,_that.reason,_that.notes);case GetCreditNotes() when getCreditNotes != null:
return getCreditNotes(_that.startDate,_that.endDate,_that.companyId,_that.page,_that.limit);case GetCompaniesWithOverdueInvoices() when getCompaniesWithOverdueInvoices != null:
return getCompaniesWithOverdueInvoices();case GetPlatformRevenueSummary() when getPlatformRevenueSummary != null:
return getPlatformRevenueSummary(_that.startDate,_that.endDate);case GetRevenueByCompany() when getRevenueByCompany != null:
return getRevenueByCompany(_that.startDate,_that.endDate);case ResetBillingState() when resetBillingState != null:
return resetBillingState();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String? searchQuery,  int page,  int limit)  loadPlatformInvoices,required TResult Function( String companyId,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)  loadCompanyInvoices,required TResult Function( String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  List<shared.InvoiceItem> items,  String? notes,  bool sendNotification)  generateInvoice,required TResult Function( List<GenerateInvoiceParams> paramsList)  generateBulkInvoices,required TResult Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)  processPayment,required TResult Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)  processPartialPayment,required TResult Function( List<ProcessPaymentParams> paramsList)  processBulkPayments,required TResult Function( DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  String? notes,  bool autoMatchTransactions,  double matchTolerance)  reconcilePayments,required TResult Function( String reconciliationId)  analyzeReconciliation,required TResult Function( ReportType type,  DateTime periodStart,  DateTime periodEnd,  String? reportName,  String? notes)  generateRevenueReport,required TResult Function( DateTime? startDate,  DateTime? endDate)  getFinancialDashboardData,required TResult Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String format)  exportInvoices,required TResult Function( String reportId,  String format)  exportRevenueReport,required TResult Function( String invoiceId,  shared.InvoiceStatus status)  updateInvoiceStatus,required TResult Function( String invoiceId)  sendInvoiceNotification,required TResult Function( String invoiceId,  double amount,  CreditNoteReason reason,  String? notes)  createCreditNote,required TResult Function( DateTime? startDate,  DateTime? endDate,  String? companyId,  int page,  int limit)  getCreditNotes,required TResult Function()  getCompaniesWithOverdueInvoices,required TResult Function( DateTime? startDate,  DateTime? endDate)  getPlatformRevenueSummary,required TResult Function( DateTime? startDate,  DateTime? endDate)  getRevenueByCompany,required TResult Function()  resetBillingState,}) {final _that = this;
switch (_that) {
case LoadPlatformInvoices():
return loadPlatformInvoices(_that.startDate,_that.endDate,_that.statuses,_that.searchQuery,_that.page,_that.limit);case LoadCompanyInvoices():
return loadCompanyInvoices(_that.companyId,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case GenerateInvoice():
return generateInvoice(_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.items,_that.notes,_that.sendNotification);case GenerateBulkInvoices():
return generateBulkInvoices(_that.paramsList);case ProcessPayment():
return processPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessPartialPayment():
return processPartialPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessBulkPayments():
return processBulkPayments(_that.paramsList);case ReconcilePayments():
return reconcilePayments(_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.notes,_that.autoMatchTransactions,_that.matchTolerance);case AnalyzeReconciliation():
return analyzeReconciliation(_that.reconciliationId);case GenerateRevenueReport():
return generateRevenueReport(_that.type,_that.periodStart,_that.periodEnd,_that.reportName,_that.notes);case GetFinancialDashboardData():
return getFinancialDashboardData(_that.startDate,_that.endDate);case ExportInvoices():
return exportInvoices(_that.startDate,_that.endDate,_that.statuses,_that.format);case ExportRevenueReport():
return exportRevenueReport(_that.reportId,_that.format);case UpdateInvoiceStatus():
return updateInvoiceStatus(_that.invoiceId,_that.status);case SendInvoiceNotification():
return sendInvoiceNotification(_that.invoiceId);case CreateCreditNote():
return createCreditNote(_that.invoiceId,_that.amount,_that.reason,_that.notes);case GetCreditNotes():
return getCreditNotes(_that.startDate,_that.endDate,_that.companyId,_that.page,_that.limit);case GetCompaniesWithOverdueInvoices():
return getCompaniesWithOverdueInvoices();case GetPlatformRevenueSummary():
return getPlatformRevenueSummary(_that.startDate,_that.endDate);case GetRevenueByCompany():
return getRevenueByCompany(_that.startDate,_that.endDate);case ResetBillingState():
return resetBillingState();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String? searchQuery,  int page,  int limit)?  loadPlatformInvoices,TResult? Function( String companyId,  DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  int page,  int limit)?  loadCompanyInvoices,TResult? Function( String companyId,  String subscriptionId,  DateTime periodStart,  DateTime periodEnd,  List<shared.InvoiceItem> items,  String? notes,  bool sendNotification)?  generateInvoice,TResult? Function( List<GenerateInvoiceParams> paramsList)?  generateBulkInvoices,TResult? Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)?  processPayment,TResult? Function( String invoiceId,  double amount,  shared.PaymentMethod method,  DateTime paymentDate,  String? reference,  String? transactionId,  String? notes,  bool sendNotification)?  processPartialPayment,TResult? Function( List<ProcessPaymentParams> paramsList)?  processBulkPayments,TResult? Function( DateTime reconciliationDate,  DateTime periodStart,  DateTime periodEnd,  String? notes,  bool autoMatchTransactions,  double matchTolerance)?  reconcilePayments,TResult? Function( String reconciliationId)?  analyzeReconciliation,TResult? Function( ReportType type,  DateTime periodStart,  DateTime periodEnd,  String? reportName,  String? notes)?  generateRevenueReport,TResult? Function( DateTime? startDate,  DateTime? endDate)?  getFinancialDashboardData,TResult? Function( DateTime? startDate,  DateTime? endDate,  List<shared.InvoiceStatus>? statuses,  String format)?  exportInvoices,TResult? Function( String reportId,  String format)?  exportRevenueReport,TResult? Function( String invoiceId,  shared.InvoiceStatus status)?  updateInvoiceStatus,TResult? Function( String invoiceId)?  sendInvoiceNotification,TResult? Function( String invoiceId,  double amount,  CreditNoteReason reason,  String? notes)?  createCreditNote,TResult? Function( DateTime? startDate,  DateTime? endDate,  String? companyId,  int page,  int limit)?  getCreditNotes,TResult? Function()?  getCompaniesWithOverdueInvoices,TResult? Function( DateTime? startDate,  DateTime? endDate)?  getPlatformRevenueSummary,TResult? Function( DateTime? startDate,  DateTime? endDate)?  getRevenueByCompany,TResult? Function()?  resetBillingState,}) {final _that = this;
switch (_that) {
case LoadPlatformInvoices() when loadPlatformInvoices != null:
return loadPlatformInvoices(_that.startDate,_that.endDate,_that.statuses,_that.searchQuery,_that.page,_that.limit);case LoadCompanyInvoices() when loadCompanyInvoices != null:
return loadCompanyInvoices(_that.companyId,_that.startDate,_that.endDate,_that.statuses,_that.page,_that.limit);case GenerateInvoice() when generateInvoice != null:
return generateInvoice(_that.companyId,_that.subscriptionId,_that.periodStart,_that.periodEnd,_that.items,_that.notes,_that.sendNotification);case GenerateBulkInvoices() when generateBulkInvoices != null:
return generateBulkInvoices(_that.paramsList);case ProcessPayment() when processPayment != null:
return processPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessPartialPayment() when processPartialPayment != null:
return processPartialPayment(_that.invoiceId,_that.amount,_that.method,_that.paymentDate,_that.reference,_that.transactionId,_that.notes,_that.sendNotification);case ProcessBulkPayments() when processBulkPayments != null:
return processBulkPayments(_that.paramsList);case ReconcilePayments() when reconcilePayments != null:
return reconcilePayments(_that.reconciliationDate,_that.periodStart,_that.periodEnd,_that.notes,_that.autoMatchTransactions,_that.matchTolerance);case AnalyzeReconciliation() when analyzeReconciliation != null:
return analyzeReconciliation(_that.reconciliationId);case GenerateRevenueReport() when generateRevenueReport != null:
return generateRevenueReport(_that.type,_that.periodStart,_that.periodEnd,_that.reportName,_that.notes);case GetFinancialDashboardData() when getFinancialDashboardData != null:
return getFinancialDashboardData(_that.startDate,_that.endDate);case ExportInvoices() when exportInvoices != null:
return exportInvoices(_that.startDate,_that.endDate,_that.statuses,_that.format);case ExportRevenueReport() when exportRevenueReport != null:
return exportRevenueReport(_that.reportId,_that.format);case UpdateInvoiceStatus() when updateInvoiceStatus != null:
return updateInvoiceStatus(_that.invoiceId,_that.status);case SendInvoiceNotification() when sendInvoiceNotification != null:
return sendInvoiceNotification(_that.invoiceId);case CreateCreditNote() when createCreditNote != null:
return createCreditNote(_that.invoiceId,_that.amount,_that.reason,_that.notes);case GetCreditNotes() when getCreditNotes != null:
return getCreditNotes(_that.startDate,_that.endDate,_that.companyId,_that.page,_that.limit);case GetCompaniesWithOverdueInvoices() when getCompaniesWithOverdueInvoices != null:
return getCompaniesWithOverdueInvoices();case GetPlatformRevenueSummary() when getPlatformRevenueSummary != null:
return getPlatformRevenueSummary(_that.startDate,_that.endDate);case GetRevenueByCompany() when getRevenueByCompany != null:
return getRevenueByCompany(_that.startDate,_that.endDate);case ResetBillingState() when resetBillingState != null:
return resetBillingState();case _:
  return null;

}
}

}

/// @nodoc


class LoadPlatformInvoices implements BillingEvent {
  const LoadPlatformInvoices({this.startDate, this.endDate, final  List<shared.InvoiceStatus>? statuses, this.searchQuery, this.page = 1, this.limit = 20}): _statuses = statuses;
  

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

 final  String? searchQuery;
@JsonKey() final  int page;
@JsonKey() final  int limit;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadPlatformInvoicesCopyWith<LoadPlatformInvoices> get copyWith => _$LoadPlatformInvoicesCopyWithImpl<LoadPlatformInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadPlatformInvoices&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),searchQuery,page,limit);

@override
String toString() {
  return 'BillingEvent.loadPlatformInvoices(startDate: $startDate, endDate: $endDate, statuses: $statuses, searchQuery: $searchQuery, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $LoadPlatformInvoicesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $LoadPlatformInvoicesCopyWith(LoadPlatformInvoices value, $Res Function(LoadPlatformInvoices) _then) = _$LoadPlatformInvoicesCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<shared.InvoiceStatus>? statuses, String? searchQuery, int page, int limit
});




}
/// @nodoc
class _$LoadPlatformInvoicesCopyWithImpl<$Res>
    implements $LoadPlatformInvoicesCopyWith<$Res> {
  _$LoadPlatformInvoicesCopyWithImpl(this._self, this._then);

  final LoadPlatformInvoices _self;
  final $Res Function(LoadPlatformInvoices) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? searchQuery = freezed,Object? page = null,Object? limit = null,}) {
  return _then(LoadPlatformInvoices(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceStatus>?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LoadCompanyInvoices implements BillingEvent {
  const LoadCompanyInvoices({required this.companyId, this.startDate, this.endDate, final  List<shared.InvoiceStatus>? statuses, this.page = 1, this.limit = 20}): _statuses = statuses;
  

 final  String companyId;
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

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadCompanyInvoicesCopyWith<LoadCompanyInvoices> get copyWith => _$LoadCompanyInvoicesCopyWithImpl<LoadCompanyInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadCompanyInvoices&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,startDate,endDate,const DeepCollectionEquality().hash(_statuses),page,limit);

@override
String toString() {
  return 'BillingEvent.loadCompanyInvoices(companyId: $companyId, startDate: $startDate, endDate: $endDate, statuses: $statuses, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $LoadCompanyInvoicesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $LoadCompanyInvoicesCopyWith(LoadCompanyInvoices value, $Res Function(LoadCompanyInvoices) _then) = _$LoadCompanyInvoicesCopyWithImpl;
@useResult
$Res call({
 String companyId, DateTime? startDate, DateTime? endDate, List<shared.InvoiceStatus>? statuses, int page, int limit
});




}
/// @nodoc
class _$LoadCompanyInvoicesCopyWithImpl<$Res>
    implements $LoadCompanyInvoicesCopyWith<$Res> {
  _$LoadCompanyInvoicesCopyWithImpl(this._self, this._then);

  final LoadCompanyInvoices _self;
  final $Res Function(LoadCompanyInvoices) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? page = null,Object? limit = null,}) {
  return _then(LoadCompanyInvoices(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceStatus>?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class GenerateInvoice implements BillingEvent {
  const GenerateInvoice({required this.companyId, required this.subscriptionId, required this.periodStart, required this.periodEnd, required final  List<shared.InvoiceItem> items, this.notes, this.sendNotification = true}): _items = items;
  

 final  String companyId;
 final  String subscriptionId;
 final  DateTime periodStart;
 final  DateTime periodEnd;
 final  List<shared.InvoiceItem> _items;
 List<shared.InvoiceItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  String? notes;
@JsonKey() final  bool sendNotification;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateInvoiceCopyWith<GenerateInvoice> get copyWith => _$GenerateInvoiceCopyWithImpl<GenerateInvoice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateInvoice&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sendNotification, sendNotification) || other.sendNotification == sendNotification));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,subscriptionId,periodStart,periodEnd,const DeepCollectionEquality().hash(_items),notes,sendNotification);

@override
String toString() {
  return 'BillingEvent.generateInvoice(companyId: $companyId, subscriptionId: $subscriptionId, periodStart: $periodStart, periodEnd: $periodEnd, items: $items, notes: $notes, sendNotification: $sendNotification)';
}


}

/// @nodoc
abstract mixin class $GenerateInvoiceCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GenerateInvoiceCopyWith(GenerateInvoice value, $Res Function(GenerateInvoice) _then) = _$GenerateInvoiceCopyWithImpl;
@useResult
$Res call({
 String companyId, String subscriptionId, DateTime periodStart, DateTime periodEnd, List<shared.InvoiceItem> items, String? notes, bool sendNotification
});




}
/// @nodoc
class _$GenerateInvoiceCopyWithImpl<$Res>
    implements $GenerateInvoiceCopyWith<$Res> {
  _$GenerateInvoiceCopyWithImpl(this._self, this._then);

  final GenerateInvoice _self;
  final $Res Function(GenerateInvoice) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? subscriptionId = null,Object? periodStart = null,Object? periodEnd = null,Object? items = null,Object? notes = freezed,Object? sendNotification = null,}) {
  return _then(GenerateInvoice(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceItem>,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sendNotification: null == sendNotification ? _self.sendNotification : sendNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class GenerateBulkInvoices implements BillingEvent {
  const GenerateBulkInvoices({required final  List<GenerateInvoiceParams> paramsList}): _paramsList = paramsList;
  

 final  List<GenerateInvoiceParams> _paramsList;
 List<GenerateInvoiceParams> get paramsList {
  if (_paramsList is EqualUnmodifiableListView) return _paramsList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paramsList);
}


/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateBulkInvoicesCopyWith<GenerateBulkInvoices> get copyWith => _$GenerateBulkInvoicesCopyWithImpl<GenerateBulkInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateBulkInvoices&&const DeepCollectionEquality().equals(other._paramsList, _paramsList));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paramsList));

@override
String toString() {
  return 'BillingEvent.generateBulkInvoices(paramsList: $paramsList)';
}


}

/// @nodoc
abstract mixin class $GenerateBulkInvoicesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GenerateBulkInvoicesCopyWith(GenerateBulkInvoices value, $Res Function(GenerateBulkInvoices) _then) = _$GenerateBulkInvoicesCopyWithImpl;
@useResult
$Res call({
 List<GenerateInvoiceParams> paramsList
});




}
/// @nodoc
class _$GenerateBulkInvoicesCopyWithImpl<$Res>
    implements $GenerateBulkInvoicesCopyWith<$Res> {
  _$GenerateBulkInvoicesCopyWithImpl(this._self, this._then);

  final GenerateBulkInvoices _self;
  final $Res Function(GenerateBulkInvoices) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paramsList = null,}) {
  return _then(GenerateBulkInvoices(
paramsList: null == paramsList ? _self._paramsList : paramsList // ignore: cast_nullable_to_non_nullable
as List<GenerateInvoiceParams>,
  ));
}


}

/// @nodoc


class ProcessPayment implements BillingEvent {
  const ProcessPayment({required this.invoiceId, required this.amount, required this.method, required this.paymentDate, this.reference, this.transactionId, this.notes, this.sendNotification = true});
  

 final  String invoiceId;
 final  double amount;
 final  shared.PaymentMethod method;
 final  DateTime paymentDate;
 final  String? reference;
 final  String? transactionId;
 final  String? notes;
@JsonKey() final  bool sendNotification;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessPaymentCopyWith<ProcessPayment> get copyWith => _$ProcessPaymentCopyWithImpl<ProcessPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessPayment&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sendNotification, sendNotification) || other.sendNotification == sendNotification));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,method,paymentDate,reference,transactionId,notes,sendNotification);

@override
String toString() {
  return 'BillingEvent.processPayment(invoiceId: $invoiceId, amount: $amount, method: $method, paymentDate: $paymentDate, reference: $reference, transactionId: $transactionId, notes: $notes, sendNotification: $sendNotification)';
}


}

/// @nodoc
abstract mixin class $ProcessPaymentCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ProcessPaymentCopyWith(ProcessPayment value, $Res Function(ProcessPayment) _then) = _$ProcessPaymentCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double amount, shared.PaymentMethod method, DateTime paymentDate, String? reference, String? transactionId, String? notes, bool sendNotification
});




}
/// @nodoc
class _$ProcessPaymentCopyWithImpl<$Res>
    implements $ProcessPaymentCopyWith<$Res> {
  _$ProcessPaymentCopyWithImpl(this._self, this._then);

  final ProcessPayment _self;
  final $Res Function(ProcessPayment) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? amount = null,Object? method = null,Object? paymentDate = null,Object? reference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? sendNotification = null,}) {
  return _then(ProcessPayment(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as shared.PaymentMethod,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sendNotification: null == sendNotification ? _self.sendNotification : sendNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ProcessPartialPayment implements BillingEvent {
  const ProcessPartialPayment({required this.invoiceId, required this.amount, required this.method, required this.paymentDate, this.reference, this.transactionId, this.notes, this.sendNotification = true});
  

 final  String invoiceId;
 final  double amount;
 final  shared.PaymentMethod method;
 final  DateTime paymentDate;
 final  String? reference;
 final  String? transactionId;
 final  String? notes;
@JsonKey() final  bool sendNotification;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessPartialPaymentCopyWith<ProcessPartialPayment> get copyWith => _$ProcessPartialPaymentCopyWithImpl<ProcessPartialPayment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessPartialPayment&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sendNotification, sendNotification) || other.sendNotification == sendNotification));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,method,paymentDate,reference,transactionId,notes,sendNotification);

@override
String toString() {
  return 'BillingEvent.processPartialPayment(invoiceId: $invoiceId, amount: $amount, method: $method, paymentDate: $paymentDate, reference: $reference, transactionId: $transactionId, notes: $notes, sendNotification: $sendNotification)';
}


}

/// @nodoc
abstract mixin class $ProcessPartialPaymentCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ProcessPartialPaymentCopyWith(ProcessPartialPayment value, $Res Function(ProcessPartialPayment) _then) = _$ProcessPartialPaymentCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double amount, shared.PaymentMethod method, DateTime paymentDate, String? reference, String? transactionId, String? notes, bool sendNotification
});




}
/// @nodoc
class _$ProcessPartialPaymentCopyWithImpl<$Res>
    implements $ProcessPartialPaymentCopyWith<$Res> {
  _$ProcessPartialPaymentCopyWithImpl(this._self, this._then);

  final ProcessPartialPayment _self;
  final $Res Function(ProcessPartialPayment) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? amount = null,Object? method = null,Object? paymentDate = null,Object? reference = freezed,Object? transactionId = freezed,Object? notes = freezed,Object? sendNotification = null,}) {
  return _then(ProcessPartialPayment(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as shared.PaymentMethod,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sendNotification: null == sendNotification ? _self.sendNotification : sendNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ProcessBulkPayments implements BillingEvent {
  const ProcessBulkPayments({required final  List<ProcessPaymentParams> paramsList}): _paramsList = paramsList;
  

 final  List<ProcessPaymentParams> _paramsList;
 List<ProcessPaymentParams> get paramsList {
  if (_paramsList is EqualUnmodifiableListView) return _paramsList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paramsList);
}


/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessBulkPaymentsCopyWith<ProcessBulkPayments> get copyWith => _$ProcessBulkPaymentsCopyWithImpl<ProcessBulkPayments>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessBulkPayments&&const DeepCollectionEquality().equals(other._paramsList, _paramsList));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paramsList));

@override
String toString() {
  return 'BillingEvent.processBulkPayments(paramsList: $paramsList)';
}


}

/// @nodoc
abstract mixin class $ProcessBulkPaymentsCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ProcessBulkPaymentsCopyWith(ProcessBulkPayments value, $Res Function(ProcessBulkPayments) _then) = _$ProcessBulkPaymentsCopyWithImpl;
@useResult
$Res call({
 List<ProcessPaymentParams> paramsList
});




}
/// @nodoc
class _$ProcessBulkPaymentsCopyWithImpl<$Res>
    implements $ProcessBulkPaymentsCopyWith<$Res> {
  _$ProcessBulkPaymentsCopyWithImpl(this._self, this._then);

  final ProcessBulkPayments _self;
  final $Res Function(ProcessBulkPayments) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paramsList = null,}) {
  return _then(ProcessBulkPayments(
paramsList: null == paramsList ? _self._paramsList : paramsList // ignore: cast_nullable_to_non_nullable
as List<ProcessPaymentParams>,
  ));
}


}

/// @nodoc


class ReconcilePayments implements BillingEvent {
  const ReconcilePayments({required this.reconciliationDate, required this.periodStart, required this.periodEnd, this.notes, this.autoMatchTransactions = true, this.matchTolerance = 0.01});
  

 final  DateTime reconciliationDate;
 final  DateTime periodStart;
 final  DateTime periodEnd;
 final  String? notes;
@JsonKey() final  bool autoMatchTransactions;
@JsonKey() final  double matchTolerance;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReconcilePaymentsCopyWith<ReconcilePayments> get copyWith => _$ReconcilePaymentsCopyWithImpl<ReconcilePayments>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReconcilePayments&&(identical(other.reconciliationDate, reconciliationDate) || other.reconciliationDate == reconciliationDate)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.autoMatchTransactions, autoMatchTransactions) || other.autoMatchTransactions == autoMatchTransactions)&&(identical(other.matchTolerance, matchTolerance) || other.matchTolerance == matchTolerance));
}


@override
int get hashCode => Object.hash(runtimeType,reconciliationDate,periodStart,periodEnd,notes,autoMatchTransactions,matchTolerance);

@override
String toString() {
  return 'BillingEvent.reconcilePayments(reconciliationDate: $reconciliationDate, periodStart: $periodStart, periodEnd: $periodEnd, notes: $notes, autoMatchTransactions: $autoMatchTransactions, matchTolerance: $matchTolerance)';
}


}

/// @nodoc
abstract mixin class $ReconcilePaymentsCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ReconcilePaymentsCopyWith(ReconcilePayments value, $Res Function(ReconcilePayments) _then) = _$ReconcilePaymentsCopyWithImpl;
@useResult
$Res call({
 DateTime reconciliationDate, DateTime periodStart, DateTime periodEnd, String? notes, bool autoMatchTransactions, double matchTolerance
});




}
/// @nodoc
class _$ReconcilePaymentsCopyWithImpl<$Res>
    implements $ReconcilePaymentsCopyWith<$Res> {
  _$ReconcilePaymentsCopyWithImpl(this._self, this._then);

  final ReconcilePayments _self;
  final $Res Function(ReconcilePayments) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reconciliationDate = null,Object? periodStart = null,Object? periodEnd = null,Object? notes = freezed,Object? autoMatchTransactions = null,Object? matchTolerance = null,}) {
  return _then(ReconcilePayments(
reconciliationDate: null == reconciliationDate ? _self.reconciliationDate : reconciliationDate // ignore: cast_nullable_to_non_nullable
as DateTime,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,autoMatchTransactions: null == autoMatchTransactions ? _self.autoMatchTransactions : autoMatchTransactions // ignore: cast_nullable_to_non_nullable
as bool,matchTolerance: null == matchTolerance ? _self.matchTolerance : matchTolerance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class AnalyzeReconciliation implements BillingEvent {
  const AnalyzeReconciliation({required this.reconciliationId});
  

 final  String reconciliationId;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyzeReconciliationCopyWith<AnalyzeReconciliation> get copyWith => _$AnalyzeReconciliationCopyWithImpl<AnalyzeReconciliation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyzeReconciliation&&(identical(other.reconciliationId, reconciliationId) || other.reconciliationId == reconciliationId));
}


@override
int get hashCode => Object.hash(runtimeType,reconciliationId);

@override
String toString() {
  return 'BillingEvent.analyzeReconciliation(reconciliationId: $reconciliationId)';
}


}

/// @nodoc
abstract mixin class $AnalyzeReconciliationCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $AnalyzeReconciliationCopyWith(AnalyzeReconciliation value, $Res Function(AnalyzeReconciliation) _then) = _$AnalyzeReconciliationCopyWithImpl;
@useResult
$Res call({
 String reconciliationId
});




}
/// @nodoc
class _$AnalyzeReconciliationCopyWithImpl<$Res>
    implements $AnalyzeReconciliationCopyWith<$Res> {
  _$AnalyzeReconciliationCopyWithImpl(this._self, this._then);

  final AnalyzeReconciliation _self;
  final $Res Function(AnalyzeReconciliation) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reconciliationId = null,}) {
  return _then(AnalyzeReconciliation(
reconciliationId: null == reconciliationId ? _self.reconciliationId : reconciliationId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GenerateRevenueReport implements BillingEvent {
  const GenerateRevenueReport({required this.type, required this.periodStart, required this.periodEnd, this.reportName, this.notes});
  

 final  ReportType type;
 final  DateTime periodStart;
 final  DateTime periodEnd;
 final  String? reportName;
 final  String? notes;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateRevenueReportCopyWith<GenerateRevenueReport> get copyWith => _$GenerateRevenueReportCopyWithImpl<GenerateRevenueReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateRevenueReport&&(identical(other.type, type) || other.type == type)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.reportName, reportName) || other.reportName == reportName)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,type,periodStart,periodEnd,reportName,notes);

@override
String toString() {
  return 'BillingEvent.generateRevenueReport(type: $type, periodStart: $periodStart, periodEnd: $periodEnd, reportName: $reportName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $GenerateRevenueReportCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GenerateRevenueReportCopyWith(GenerateRevenueReport value, $Res Function(GenerateRevenueReport) _then) = _$GenerateRevenueReportCopyWithImpl;
@useResult
$Res call({
 ReportType type, DateTime periodStart, DateTime periodEnd, String? reportName, String? notes
});




}
/// @nodoc
class _$GenerateRevenueReportCopyWithImpl<$Res>
    implements $GenerateRevenueReportCopyWith<$Res> {
  _$GenerateRevenueReportCopyWithImpl(this._self, this._then);

  final GenerateRevenueReport _self;
  final $Res Function(GenerateRevenueReport) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? type = null,Object? periodStart = null,Object? periodEnd = null,Object? reportName = freezed,Object? notes = freezed,}) {
  return _then(GenerateRevenueReport(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReportType,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,reportName: freezed == reportName ? _self.reportName : reportName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GetFinancialDashboardData implements BillingEvent {
  const GetFinancialDashboardData({this.startDate, this.endDate});
  

 final  DateTime? startDate;
 final  DateTime? endDate;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetFinancialDashboardDataCopyWith<GetFinancialDashboardData> get copyWith => _$GetFinancialDashboardDataCopyWithImpl<GetFinancialDashboardData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetFinancialDashboardData&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate);

@override
String toString() {
  return 'BillingEvent.getFinancialDashboardData(startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $GetFinancialDashboardDataCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GetFinancialDashboardDataCopyWith(GetFinancialDashboardData value, $Res Function(GetFinancialDashboardData) _then) = _$GetFinancialDashboardDataCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$GetFinancialDashboardDataCopyWithImpl<$Res>
    implements $GetFinancialDashboardDataCopyWith<$Res> {
  _$GetFinancialDashboardDataCopyWithImpl(this._self, this._then);

  final GetFinancialDashboardData _self;
  final $Res Function(GetFinancialDashboardData) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(GetFinancialDashboardData(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ExportInvoices implements BillingEvent {
  const ExportInvoices({this.startDate, this.endDate, final  List<shared.InvoiceStatus>? statuses, this.format = 'csv'}): _statuses = statuses;
  

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

@JsonKey() final  String format;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportInvoicesCopyWith<ExportInvoices> get copyWith => _$ExportInvoicesCopyWithImpl<ExportInvoices>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportInvoices&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,const DeepCollectionEquality().hash(_statuses),format);

@override
String toString() {
  return 'BillingEvent.exportInvoices(startDate: $startDate, endDate: $endDate, statuses: $statuses, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportInvoicesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ExportInvoicesCopyWith(ExportInvoices value, $Res Function(ExportInvoices) _then) = _$ExportInvoicesCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, List<shared.InvoiceStatus>? statuses, String format
});




}
/// @nodoc
class _$ExportInvoicesCopyWithImpl<$Res>
    implements $ExportInvoicesCopyWith<$Res> {
  _$ExportInvoicesCopyWithImpl(this._self, this._then);

  final ExportInvoices _self;
  final $Res Function(ExportInvoices) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? statuses = freezed,Object? format = null,}) {
  return _then(ExportInvoices(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,statuses: freezed == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<shared.InvoiceStatus>?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExportRevenueReport implements BillingEvent {
  const ExportRevenueReport({required this.reportId, this.format = 'pdf'});
  

 final  String reportId;
@JsonKey() final  String format;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportRevenueReportCopyWith<ExportRevenueReport> get copyWith => _$ExportRevenueReportCopyWithImpl<ExportRevenueReport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportRevenueReport&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.format, format) || other.format == format));
}


@override
int get hashCode => Object.hash(runtimeType,reportId,format);

@override
String toString() {
  return 'BillingEvent.exportRevenueReport(reportId: $reportId, format: $format)';
}


}

/// @nodoc
abstract mixin class $ExportRevenueReportCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $ExportRevenueReportCopyWith(ExportRevenueReport value, $Res Function(ExportRevenueReport) _then) = _$ExportRevenueReportCopyWithImpl;
@useResult
$Res call({
 String reportId, String format
});




}
/// @nodoc
class _$ExportRevenueReportCopyWithImpl<$Res>
    implements $ExportRevenueReportCopyWith<$Res> {
  _$ExportRevenueReportCopyWithImpl(this._self, this._then);

  final ExportRevenueReport _self;
  final $Res Function(ExportRevenueReport) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? format = null,}) {
  return _then(ExportRevenueReport(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdateInvoiceStatus implements BillingEvent {
  const UpdateInvoiceStatus({required this.invoiceId, required this.status});
  

 final  String invoiceId;
 final  shared.InvoiceStatus status;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInvoiceStatusCopyWith<UpdateInvoiceStatus> get copyWith => _$UpdateInvoiceStatusCopyWithImpl<UpdateInvoiceStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInvoiceStatus&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,status);

@override
String toString() {
  return 'BillingEvent.updateInvoiceStatus(invoiceId: $invoiceId, status: $status)';
}


}

/// @nodoc
abstract mixin class $UpdateInvoiceStatusCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $UpdateInvoiceStatusCopyWith(UpdateInvoiceStatus value, $Res Function(UpdateInvoiceStatus) _then) = _$UpdateInvoiceStatusCopyWithImpl;
@useResult
$Res call({
 String invoiceId, shared.InvoiceStatus status
});




}
/// @nodoc
class _$UpdateInvoiceStatusCopyWithImpl<$Res>
    implements $UpdateInvoiceStatusCopyWith<$Res> {
  _$UpdateInvoiceStatusCopyWithImpl(this._self, this._then);

  final UpdateInvoiceStatus _self;
  final $Res Function(UpdateInvoiceStatus) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? status = null,}) {
  return _then(UpdateInvoiceStatus(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as shared.InvoiceStatus,
  ));
}


}

/// @nodoc


class SendInvoiceNotification implements BillingEvent {
  const SendInvoiceNotification({required this.invoiceId});
  

 final  String invoiceId;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendInvoiceNotificationCopyWith<SendInvoiceNotification> get copyWith => _$SendInvoiceNotificationCopyWithImpl<SendInvoiceNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendInvoiceNotification&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId);

@override
String toString() {
  return 'BillingEvent.sendInvoiceNotification(invoiceId: $invoiceId)';
}


}

/// @nodoc
abstract mixin class $SendInvoiceNotificationCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $SendInvoiceNotificationCopyWith(SendInvoiceNotification value, $Res Function(SendInvoiceNotification) _then) = _$SendInvoiceNotificationCopyWithImpl;
@useResult
$Res call({
 String invoiceId
});




}
/// @nodoc
class _$SendInvoiceNotificationCopyWithImpl<$Res>
    implements $SendInvoiceNotificationCopyWith<$Res> {
  _$SendInvoiceNotificationCopyWithImpl(this._self, this._then);

  final SendInvoiceNotification _self;
  final $Res Function(SendInvoiceNotification) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,}) {
  return _then(SendInvoiceNotification(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CreateCreditNote implements BillingEvent {
  const CreateCreditNote({required this.invoiceId, required this.amount, required this.reason, this.notes});
  

 final  String invoiceId;
 final  double amount;
 final  CreditNoteReason reason;
 final  String? notes;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCreditNoteCopyWith<CreateCreditNote> get copyWith => _$CreateCreditNoteCopyWithImpl<CreateCreditNote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCreditNote&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,reason,notes);

@override
String toString() {
  return 'BillingEvent.createCreditNote(invoiceId: $invoiceId, amount: $amount, reason: $reason, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateCreditNoteCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $CreateCreditNoteCopyWith(CreateCreditNote value, $Res Function(CreateCreditNote) _then) = _$CreateCreditNoteCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double amount, CreditNoteReason reason, String? notes
});




}
/// @nodoc
class _$CreateCreditNoteCopyWithImpl<$Res>
    implements $CreateCreditNoteCopyWith<$Res> {
  _$CreateCreditNoteCopyWithImpl(this._self, this._then);

  final CreateCreditNote _self;
  final $Res Function(CreateCreditNote) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? amount = null,Object? reason = null,Object? notes = freezed,}) {
  return _then(CreateCreditNote(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as CreditNoteReason,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class GetCreditNotes implements BillingEvent {
  const GetCreditNotes({this.startDate, this.endDate, this.companyId, this.page = 1, this.limit = 20});
  

 final  DateTime? startDate;
 final  DateTime? endDate;
 final  String? companyId;
@JsonKey() final  int page;
@JsonKey() final  int limit;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetCreditNotesCopyWith<GetCreditNotes> get copyWith => _$GetCreditNotesCopyWithImpl<GetCreditNotes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCreditNotes&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate,companyId,page,limit);

@override
String toString() {
  return 'BillingEvent.getCreditNotes(startDate: $startDate, endDate: $endDate, companyId: $companyId, page: $page, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $GetCreditNotesCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GetCreditNotesCopyWith(GetCreditNotes value, $Res Function(GetCreditNotes) _then) = _$GetCreditNotesCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate, String? companyId, int page, int limit
});




}
/// @nodoc
class _$GetCreditNotesCopyWithImpl<$Res>
    implements $GetCreditNotesCopyWith<$Res> {
  _$GetCreditNotesCopyWithImpl(this._self, this._then);

  final GetCreditNotes _self;
  final $Res Function(GetCreditNotes) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,Object? companyId = freezed,Object? page = null,Object? limit = null,}) {
  return _then(GetCreditNotes(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class GetCompaniesWithOverdueInvoices implements BillingEvent {
  const GetCompaniesWithOverdueInvoices();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetCompaniesWithOverdueInvoices);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.getCompaniesWithOverdueInvoices()';
}


}




/// @nodoc


class GetPlatformRevenueSummary implements BillingEvent {
  const GetPlatformRevenueSummary({this.startDate, this.endDate});
  

 final  DateTime? startDate;
 final  DateTime? endDate;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetPlatformRevenueSummaryCopyWith<GetPlatformRevenueSummary> get copyWith => _$GetPlatformRevenueSummaryCopyWithImpl<GetPlatformRevenueSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetPlatformRevenueSummary&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate);

@override
String toString() {
  return 'BillingEvent.getPlatformRevenueSummary(startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $GetPlatformRevenueSummaryCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GetPlatformRevenueSummaryCopyWith(GetPlatformRevenueSummary value, $Res Function(GetPlatformRevenueSummary) _then) = _$GetPlatformRevenueSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$GetPlatformRevenueSummaryCopyWithImpl<$Res>
    implements $GetPlatformRevenueSummaryCopyWith<$Res> {
  _$GetPlatformRevenueSummaryCopyWithImpl(this._self, this._then);

  final GetPlatformRevenueSummary _self;
  final $Res Function(GetPlatformRevenueSummary) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(GetPlatformRevenueSummary(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class GetRevenueByCompany implements BillingEvent {
  const GetRevenueByCompany({this.startDate, this.endDate});
  

 final  DateTime? startDate;
 final  DateTime? endDate;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetRevenueByCompanyCopyWith<GetRevenueByCompany> get copyWith => _$GetRevenueByCompanyCopyWithImpl<GetRevenueByCompany>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetRevenueByCompany&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,startDate,endDate);

@override
String toString() {
  return 'BillingEvent.getRevenueByCompany(startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $GetRevenueByCompanyCopyWith<$Res> implements $BillingEventCopyWith<$Res> {
  factory $GetRevenueByCompanyCopyWith(GetRevenueByCompany value, $Res Function(GetRevenueByCompany) _then) = _$GetRevenueByCompanyCopyWithImpl;
@useResult
$Res call({
 DateTime? startDate, DateTime? endDate
});




}
/// @nodoc
class _$GetRevenueByCompanyCopyWithImpl<$Res>
    implements $GetRevenueByCompanyCopyWith<$Res> {
  _$GetRevenueByCompanyCopyWithImpl(this._self, this._then);

  final GetRevenueByCompany _self;
  final $Res Function(GetRevenueByCompany) _then;

/// Create a copy of BillingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(GetRevenueByCompany(
startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class ResetBillingState implements BillingEvent {
  const ResetBillingState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetBillingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingEvent.resetBillingState()';
}


}




// dart format on

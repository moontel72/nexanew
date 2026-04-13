// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Processing value)?  processing,TResult Function( _PlatformInvoicesLoaded value)?  platformInvoicesLoaded,TResult Function( _CompanyInvoicesLoaded value)?  companyInvoicesLoaded,TResult Function( _InvoiceGenerated value)?  invoiceGenerated,TResult Function( _BulkInvoicesGenerated value)?  bulkInvoicesGenerated,TResult Function( _PaymentProcessed value)?  paymentProcessed,TResult Function( _PartialPaymentProcessed value)?  partialPaymentProcessed,TResult Function( _BulkPaymentsProcessed value)?  bulkPaymentsProcessed,TResult Function( _PaymentsReconciled value)?  paymentsReconciled,TResult Function( _ReconciliationAnalyzed value)?  reconciliationAnalyzed,TResult Function( _RevenueReportGenerated value)?  revenueReportGenerated,TResult Function( _FinancialDashboardLoaded value)?  financialDashboardLoaded,TResult Function( _InvoicesExported value)?  invoicesExported,TResult Function( _RevenueReportExported value)?  revenueReportExported,TResult Function( _InvoiceStatusUpdated value)?  invoiceStatusUpdated,TResult Function( _CreditNoteCreated value)?  creditNoteCreated,TResult Function( _CreditNotesLoaded value)?  creditNotesLoaded,TResult Function( _CompaniesWithOverdueLoaded value)?  companiesWithOverdueLoaded,TResult Function( _PlatformRevenueSummaryLoaded value)?  platformRevenueSummaryLoaded,TResult Function( _RevenueByCompanyLoaded value)?  revenueByCompanyLoaded,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,TResult Function( _Empty value)?  empty,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Processing() when processing != null:
return processing(_that);case _PlatformInvoicesLoaded() when platformInvoicesLoaded != null:
return platformInvoicesLoaded(_that);case _CompanyInvoicesLoaded() when companyInvoicesLoaded != null:
return companyInvoicesLoaded(_that);case _InvoiceGenerated() when invoiceGenerated != null:
return invoiceGenerated(_that);case _BulkInvoicesGenerated() when bulkInvoicesGenerated != null:
return bulkInvoicesGenerated(_that);case _PaymentProcessed() when paymentProcessed != null:
return paymentProcessed(_that);case _PartialPaymentProcessed() when partialPaymentProcessed != null:
return partialPaymentProcessed(_that);case _BulkPaymentsProcessed() when bulkPaymentsProcessed != null:
return bulkPaymentsProcessed(_that);case _PaymentsReconciled() when paymentsReconciled != null:
return paymentsReconciled(_that);case _ReconciliationAnalyzed() when reconciliationAnalyzed != null:
return reconciliationAnalyzed(_that);case _RevenueReportGenerated() when revenueReportGenerated != null:
return revenueReportGenerated(_that);case _FinancialDashboardLoaded() when financialDashboardLoaded != null:
return financialDashboardLoaded(_that);case _InvoicesExported() when invoicesExported != null:
return invoicesExported(_that);case _RevenueReportExported() when revenueReportExported != null:
return revenueReportExported(_that);case _InvoiceStatusUpdated() when invoiceStatusUpdated != null:
return invoiceStatusUpdated(_that);case _CreditNoteCreated() when creditNoteCreated != null:
return creditNoteCreated(_that);case _CreditNotesLoaded() when creditNotesLoaded != null:
return creditNotesLoaded(_that);case _CompaniesWithOverdueLoaded() when companiesWithOverdueLoaded != null:
return companiesWithOverdueLoaded(_that);case _PlatformRevenueSummaryLoaded() when platformRevenueSummaryLoaded != null:
return platformRevenueSummaryLoaded(_that);case _RevenueByCompanyLoaded() when revenueByCompanyLoaded != null:
return revenueByCompanyLoaded(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _Empty() when empty != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Processing value)  processing,required TResult Function( _PlatformInvoicesLoaded value)  platformInvoicesLoaded,required TResult Function( _CompanyInvoicesLoaded value)  companyInvoicesLoaded,required TResult Function( _InvoiceGenerated value)  invoiceGenerated,required TResult Function( _BulkInvoicesGenerated value)  bulkInvoicesGenerated,required TResult Function( _PaymentProcessed value)  paymentProcessed,required TResult Function( _PartialPaymentProcessed value)  partialPaymentProcessed,required TResult Function( _BulkPaymentsProcessed value)  bulkPaymentsProcessed,required TResult Function( _PaymentsReconciled value)  paymentsReconciled,required TResult Function( _ReconciliationAnalyzed value)  reconciliationAnalyzed,required TResult Function( _RevenueReportGenerated value)  revenueReportGenerated,required TResult Function( _FinancialDashboardLoaded value)  financialDashboardLoaded,required TResult Function( _InvoicesExported value)  invoicesExported,required TResult Function( _RevenueReportExported value)  revenueReportExported,required TResult Function( _InvoiceStatusUpdated value)  invoiceStatusUpdated,required TResult Function( _CreditNoteCreated value)  creditNoteCreated,required TResult Function( _CreditNotesLoaded value)  creditNotesLoaded,required TResult Function( _CompaniesWithOverdueLoaded value)  companiesWithOverdueLoaded,required TResult Function( _PlatformRevenueSummaryLoaded value)  platformRevenueSummaryLoaded,required TResult Function( _RevenueByCompanyLoaded value)  revenueByCompanyLoaded,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,required TResult Function( _Empty value)  empty,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Processing():
return processing(_that);case _PlatformInvoicesLoaded():
return platformInvoicesLoaded(_that);case _CompanyInvoicesLoaded():
return companyInvoicesLoaded(_that);case _InvoiceGenerated():
return invoiceGenerated(_that);case _BulkInvoicesGenerated():
return bulkInvoicesGenerated(_that);case _PaymentProcessed():
return paymentProcessed(_that);case _PartialPaymentProcessed():
return partialPaymentProcessed(_that);case _BulkPaymentsProcessed():
return bulkPaymentsProcessed(_that);case _PaymentsReconciled():
return paymentsReconciled(_that);case _ReconciliationAnalyzed():
return reconciliationAnalyzed(_that);case _RevenueReportGenerated():
return revenueReportGenerated(_that);case _FinancialDashboardLoaded():
return financialDashboardLoaded(_that);case _InvoicesExported():
return invoicesExported(_that);case _RevenueReportExported():
return revenueReportExported(_that);case _InvoiceStatusUpdated():
return invoiceStatusUpdated(_that);case _CreditNoteCreated():
return creditNoteCreated(_that);case _CreditNotesLoaded():
return creditNotesLoaded(_that);case _CompaniesWithOverdueLoaded():
return companiesWithOverdueLoaded(_that);case _PlatformRevenueSummaryLoaded():
return platformRevenueSummaryLoaded(_that);case _RevenueByCompanyLoaded():
return revenueByCompanyLoaded(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _Empty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Processing value)?  processing,TResult? Function( _PlatformInvoicesLoaded value)?  platformInvoicesLoaded,TResult? Function( _CompanyInvoicesLoaded value)?  companyInvoicesLoaded,TResult? Function( _InvoiceGenerated value)?  invoiceGenerated,TResult? Function( _BulkInvoicesGenerated value)?  bulkInvoicesGenerated,TResult? Function( _PaymentProcessed value)?  paymentProcessed,TResult? Function( _PartialPaymentProcessed value)?  partialPaymentProcessed,TResult? Function( _BulkPaymentsProcessed value)?  bulkPaymentsProcessed,TResult? Function( _PaymentsReconciled value)?  paymentsReconciled,TResult? Function( _ReconciliationAnalyzed value)?  reconciliationAnalyzed,TResult? Function( _RevenueReportGenerated value)?  revenueReportGenerated,TResult? Function( _FinancialDashboardLoaded value)?  financialDashboardLoaded,TResult? Function( _InvoicesExported value)?  invoicesExported,TResult? Function( _RevenueReportExported value)?  revenueReportExported,TResult? Function( _InvoiceStatusUpdated value)?  invoiceStatusUpdated,TResult? Function( _CreditNoteCreated value)?  creditNoteCreated,TResult? Function( _CreditNotesLoaded value)?  creditNotesLoaded,TResult? Function( _CompaniesWithOverdueLoaded value)?  companiesWithOverdueLoaded,TResult? Function( _PlatformRevenueSummaryLoaded value)?  platformRevenueSummaryLoaded,TResult? Function( _RevenueByCompanyLoaded value)?  revenueByCompanyLoaded,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,TResult? Function( _Empty value)?  empty,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Processing() when processing != null:
return processing(_that);case _PlatformInvoicesLoaded() when platformInvoicesLoaded != null:
return platformInvoicesLoaded(_that);case _CompanyInvoicesLoaded() when companyInvoicesLoaded != null:
return companyInvoicesLoaded(_that);case _InvoiceGenerated() when invoiceGenerated != null:
return invoiceGenerated(_that);case _BulkInvoicesGenerated() when bulkInvoicesGenerated != null:
return bulkInvoicesGenerated(_that);case _PaymentProcessed() when paymentProcessed != null:
return paymentProcessed(_that);case _PartialPaymentProcessed() when partialPaymentProcessed != null:
return partialPaymentProcessed(_that);case _BulkPaymentsProcessed() when bulkPaymentsProcessed != null:
return bulkPaymentsProcessed(_that);case _PaymentsReconciled() when paymentsReconciled != null:
return paymentsReconciled(_that);case _ReconciliationAnalyzed() when reconciliationAnalyzed != null:
return reconciliationAnalyzed(_that);case _RevenueReportGenerated() when revenueReportGenerated != null:
return revenueReportGenerated(_that);case _FinancialDashboardLoaded() when financialDashboardLoaded != null:
return financialDashboardLoaded(_that);case _InvoicesExported() when invoicesExported != null:
return invoicesExported(_that);case _RevenueReportExported() when revenueReportExported != null:
return revenueReportExported(_that);case _InvoiceStatusUpdated() when invoiceStatusUpdated != null:
return invoiceStatusUpdated(_that);case _CreditNoteCreated() when creditNoteCreated != null:
return creditNoteCreated(_that);case _CreditNotesLoaded() when creditNotesLoaded != null:
return creditNotesLoaded(_that);case _CompaniesWithOverdueLoaded() when companiesWithOverdueLoaded != null:
return companiesWithOverdueLoaded(_that);case _PlatformRevenueSummaryLoaded() when platformRevenueSummaryLoaded != null:
return platformRevenueSummaryLoaded(_that);case _RevenueByCompanyLoaded() when revenueByCompanyLoaded != null:
return revenueByCompanyLoaded(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _Empty() when empty != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  processing,TResult Function( List<AdminInvoice> invoices,  bool hasMore,  int currentPage)?  platformInvoicesLoaded,TResult Function( String companyId,  List<AdminInvoice> invoices,  bool hasMore,  int currentPage)?  companyInvoicesLoaded,TResult Function( BillingEntity invoice,  String message)?  invoiceGenerated,TResult Function( List<BillingEntity> invoices,  String message,  int failedCount)?  bulkInvoicesGenerated,TResult Function( BillingEntity payment,  String message)?  paymentProcessed,TResult Function( BillingEntity payment,  String message)?  partialPaymentProcessed,TResult Function( List<BillingEntity> payments,  String message,  int failedCount)?  bulkPaymentsProcessed,TResult Function( PaymentReconciliation reconciliation,  String message)?  paymentsReconciled,TResult Function( ReconciliationAnalysis analysis,  String message)?  reconciliationAnalyzed,TResult Function( RevenueReport report,  String message)?  revenueReportGenerated,TResult Function( Map<String, dynamic> dashboardData,  String message)?  financialDashboardLoaded,TResult Function( String exportUrl,  String message)?  invoicesExported,TResult Function( String exportUrl,  String message)?  revenueReportExported,TResult Function( AdminInvoice invoice,  String message)?  invoiceStatusUpdated,TResult Function( CreditNote creditNote,  String message)?  creditNoteCreated,TResult Function( List<CreditNote> creditNotes,  bool hasMore,  int currentPage)?  creditNotesLoaded,TResult Function( List<Company> companies,  String message)?  companiesWithOverdueLoaded,TResult Function( PlatformRevenueSummary revenueSummary,  String message)?  platformRevenueSummaryLoaded,TResult Function( List<CompanyRevenueSummary> revenueByCompany,  String message)?  revenueByCompanyLoaded,TResult Function( String message)?  success,TResult Function( String message,  Failure error)?  error,TResult Function( String message)?  empty,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Processing() when processing != null:
return processing();case _PlatformInvoicesLoaded() when platformInvoicesLoaded != null:
return platformInvoicesLoaded(_that.invoices,_that.hasMore,_that.currentPage);case _CompanyInvoicesLoaded() when companyInvoicesLoaded != null:
return companyInvoicesLoaded(_that.companyId,_that.invoices,_that.hasMore,_that.currentPage);case _InvoiceGenerated() when invoiceGenerated != null:
return invoiceGenerated(_that.invoice,_that.message);case _BulkInvoicesGenerated() when bulkInvoicesGenerated != null:
return bulkInvoicesGenerated(_that.invoices,_that.message,_that.failedCount);case _PaymentProcessed() when paymentProcessed != null:
return paymentProcessed(_that.payment,_that.message);case _PartialPaymentProcessed() when partialPaymentProcessed != null:
return partialPaymentProcessed(_that.payment,_that.message);case _BulkPaymentsProcessed() when bulkPaymentsProcessed != null:
return bulkPaymentsProcessed(_that.payments,_that.message,_that.failedCount);case _PaymentsReconciled() when paymentsReconciled != null:
return paymentsReconciled(_that.reconciliation,_that.message);case _ReconciliationAnalyzed() when reconciliationAnalyzed != null:
return reconciliationAnalyzed(_that.analysis,_that.message);case _RevenueReportGenerated() when revenueReportGenerated != null:
return revenueReportGenerated(_that.report,_that.message);case _FinancialDashboardLoaded() when financialDashboardLoaded != null:
return financialDashboardLoaded(_that.dashboardData,_that.message);case _InvoicesExported() when invoicesExported != null:
return invoicesExported(_that.exportUrl,_that.message);case _RevenueReportExported() when revenueReportExported != null:
return revenueReportExported(_that.exportUrl,_that.message);case _InvoiceStatusUpdated() when invoiceStatusUpdated != null:
return invoiceStatusUpdated(_that.invoice,_that.message);case _CreditNoteCreated() when creditNoteCreated != null:
return creditNoteCreated(_that.creditNote,_that.message);case _CreditNotesLoaded() when creditNotesLoaded != null:
return creditNotesLoaded(_that.creditNotes,_that.hasMore,_that.currentPage);case _CompaniesWithOverdueLoaded() when companiesWithOverdueLoaded != null:
return companiesWithOverdueLoaded(_that.companies,_that.message);case _PlatformRevenueSummaryLoaded() when platformRevenueSummaryLoaded != null:
return platformRevenueSummaryLoaded(_that.revenueSummary,_that.message);case _RevenueByCompanyLoaded() when revenueByCompanyLoaded != null:
return revenueByCompanyLoaded(_that.revenueByCompany,_that.message);case _Success() when success != null:
return success(_that.message);case _Error() when error != null:
return error(_that.message,_that.error);case _Empty() when empty != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  processing,required TResult Function( List<AdminInvoice> invoices,  bool hasMore,  int currentPage)  platformInvoicesLoaded,required TResult Function( String companyId,  List<AdminInvoice> invoices,  bool hasMore,  int currentPage)  companyInvoicesLoaded,required TResult Function( BillingEntity invoice,  String message)  invoiceGenerated,required TResult Function( List<BillingEntity> invoices,  String message,  int failedCount)  bulkInvoicesGenerated,required TResult Function( BillingEntity payment,  String message)  paymentProcessed,required TResult Function( BillingEntity payment,  String message)  partialPaymentProcessed,required TResult Function( List<BillingEntity> payments,  String message,  int failedCount)  bulkPaymentsProcessed,required TResult Function( PaymentReconciliation reconciliation,  String message)  paymentsReconciled,required TResult Function( ReconciliationAnalysis analysis,  String message)  reconciliationAnalyzed,required TResult Function( RevenueReport report,  String message)  revenueReportGenerated,required TResult Function( Map<String, dynamic> dashboardData,  String message)  financialDashboardLoaded,required TResult Function( String exportUrl,  String message)  invoicesExported,required TResult Function( String exportUrl,  String message)  revenueReportExported,required TResult Function( AdminInvoice invoice,  String message)  invoiceStatusUpdated,required TResult Function( CreditNote creditNote,  String message)  creditNoteCreated,required TResult Function( List<CreditNote> creditNotes,  bool hasMore,  int currentPage)  creditNotesLoaded,required TResult Function( List<Company> companies,  String message)  companiesWithOverdueLoaded,required TResult Function( PlatformRevenueSummary revenueSummary,  String message)  platformRevenueSummaryLoaded,required TResult Function( List<CompanyRevenueSummary> revenueByCompany,  String message)  revenueByCompanyLoaded,required TResult Function( String message)  success,required TResult Function( String message,  Failure error)  error,required TResult Function( String message)  empty,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Processing():
return processing();case _PlatformInvoicesLoaded():
return platformInvoicesLoaded(_that.invoices,_that.hasMore,_that.currentPage);case _CompanyInvoicesLoaded():
return companyInvoicesLoaded(_that.companyId,_that.invoices,_that.hasMore,_that.currentPage);case _InvoiceGenerated():
return invoiceGenerated(_that.invoice,_that.message);case _BulkInvoicesGenerated():
return bulkInvoicesGenerated(_that.invoices,_that.message,_that.failedCount);case _PaymentProcessed():
return paymentProcessed(_that.payment,_that.message);case _PartialPaymentProcessed():
return partialPaymentProcessed(_that.payment,_that.message);case _BulkPaymentsProcessed():
return bulkPaymentsProcessed(_that.payments,_that.message,_that.failedCount);case _PaymentsReconciled():
return paymentsReconciled(_that.reconciliation,_that.message);case _ReconciliationAnalyzed():
return reconciliationAnalyzed(_that.analysis,_that.message);case _RevenueReportGenerated():
return revenueReportGenerated(_that.report,_that.message);case _FinancialDashboardLoaded():
return financialDashboardLoaded(_that.dashboardData,_that.message);case _InvoicesExported():
return invoicesExported(_that.exportUrl,_that.message);case _RevenueReportExported():
return revenueReportExported(_that.exportUrl,_that.message);case _InvoiceStatusUpdated():
return invoiceStatusUpdated(_that.invoice,_that.message);case _CreditNoteCreated():
return creditNoteCreated(_that.creditNote,_that.message);case _CreditNotesLoaded():
return creditNotesLoaded(_that.creditNotes,_that.hasMore,_that.currentPage);case _CompaniesWithOverdueLoaded():
return companiesWithOverdueLoaded(_that.companies,_that.message);case _PlatformRevenueSummaryLoaded():
return platformRevenueSummaryLoaded(_that.revenueSummary,_that.message);case _RevenueByCompanyLoaded():
return revenueByCompanyLoaded(_that.revenueByCompany,_that.message);case _Success():
return success(_that.message);case _Error():
return error(_that.message,_that.error);case _Empty():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  processing,TResult? Function( List<AdminInvoice> invoices,  bool hasMore,  int currentPage)?  platformInvoicesLoaded,TResult? Function( String companyId,  List<AdminInvoice> invoices,  bool hasMore,  int currentPage)?  companyInvoicesLoaded,TResult? Function( BillingEntity invoice,  String message)?  invoiceGenerated,TResult? Function( List<BillingEntity> invoices,  String message,  int failedCount)?  bulkInvoicesGenerated,TResult? Function( BillingEntity payment,  String message)?  paymentProcessed,TResult? Function( BillingEntity payment,  String message)?  partialPaymentProcessed,TResult? Function( List<BillingEntity> payments,  String message,  int failedCount)?  bulkPaymentsProcessed,TResult? Function( PaymentReconciliation reconciliation,  String message)?  paymentsReconciled,TResult? Function( ReconciliationAnalysis analysis,  String message)?  reconciliationAnalyzed,TResult? Function( RevenueReport report,  String message)?  revenueReportGenerated,TResult? Function( Map<String, dynamic> dashboardData,  String message)?  financialDashboardLoaded,TResult? Function( String exportUrl,  String message)?  invoicesExported,TResult? Function( String exportUrl,  String message)?  revenueReportExported,TResult? Function( AdminInvoice invoice,  String message)?  invoiceStatusUpdated,TResult? Function( CreditNote creditNote,  String message)?  creditNoteCreated,TResult? Function( List<CreditNote> creditNotes,  bool hasMore,  int currentPage)?  creditNotesLoaded,TResult? Function( List<Company> companies,  String message)?  companiesWithOverdueLoaded,TResult? Function( PlatformRevenueSummary revenueSummary,  String message)?  platformRevenueSummaryLoaded,TResult? Function( List<CompanyRevenueSummary> revenueByCompany,  String message)?  revenueByCompanyLoaded,TResult? Function( String message)?  success,TResult? Function( String message,  Failure error)?  error,TResult? Function( String message)?  empty,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Processing() when processing != null:
return processing();case _PlatformInvoicesLoaded() when platformInvoicesLoaded != null:
return platformInvoicesLoaded(_that.invoices,_that.hasMore,_that.currentPage);case _CompanyInvoicesLoaded() when companyInvoicesLoaded != null:
return companyInvoicesLoaded(_that.companyId,_that.invoices,_that.hasMore,_that.currentPage);case _InvoiceGenerated() when invoiceGenerated != null:
return invoiceGenerated(_that.invoice,_that.message);case _BulkInvoicesGenerated() when bulkInvoicesGenerated != null:
return bulkInvoicesGenerated(_that.invoices,_that.message,_that.failedCount);case _PaymentProcessed() when paymentProcessed != null:
return paymentProcessed(_that.payment,_that.message);case _PartialPaymentProcessed() when partialPaymentProcessed != null:
return partialPaymentProcessed(_that.payment,_that.message);case _BulkPaymentsProcessed() when bulkPaymentsProcessed != null:
return bulkPaymentsProcessed(_that.payments,_that.message,_that.failedCount);case _PaymentsReconciled() when paymentsReconciled != null:
return paymentsReconciled(_that.reconciliation,_that.message);case _ReconciliationAnalyzed() when reconciliationAnalyzed != null:
return reconciliationAnalyzed(_that.analysis,_that.message);case _RevenueReportGenerated() when revenueReportGenerated != null:
return revenueReportGenerated(_that.report,_that.message);case _FinancialDashboardLoaded() when financialDashboardLoaded != null:
return financialDashboardLoaded(_that.dashboardData,_that.message);case _InvoicesExported() when invoicesExported != null:
return invoicesExported(_that.exportUrl,_that.message);case _RevenueReportExported() when revenueReportExported != null:
return revenueReportExported(_that.exportUrl,_that.message);case _InvoiceStatusUpdated() when invoiceStatusUpdated != null:
return invoiceStatusUpdated(_that.invoice,_that.message);case _CreditNoteCreated() when creditNoteCreated != null:
return creditNoteCreated(_that.creditNote,_that.message);case _CreditNotesLoaded() when creditNotesLoaded != null:
return creditNotesLoaded(_that.creditNotes,_that.hasMore,_that.currentPage);case _CompaniesWithOverdueLoaded() when companiesWithOverdueLoaded != null:
return companiesWithOverdueLoaded(_that.companies,_that.message);case _PlatformRevenueSummaryLoaded() when platformRevenueSummaryLoaded != null:
return platformRevenueSummaryLoaded(_that.revenueSummary,_that.message);case _RevenueByCompanyLoaded() when revenueByCompanyLoaded != null:
return revenueByCompanyLoaded(_that.revenueByCompany,_that.message);case _Success() when success != null:
return success(_that.message);case _Error() when error != null:
return error(_that.message,_that.error);case _Empty() when empty != null:
return empty(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements BillingState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState.initial()';
}


}




/// @nodoc


class _Loading implements BillingState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState.loading()';
}


}




/// @nodoc


class _Processing implements BillingState {
  const _Processing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Processing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BillingState.processing()';
}


}




/// @nodoc


class _PlatformInvoicesLoaded implements BillingState {
  const _PlatformInvoicesLoaded({required final  List<AdminInvoice> invoices, required this.hasMore, required this.currentPage}): _invoices = invoices;
  

 final  List<AdminInvoice> _invoices;
 List<AdminInvoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

 final  bool hasMore;
 final  int currentPage;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformInvoicesLoadedCopyWith<_PlatformInvoicesLoaded> get copyWith => __$PlatformInvoicesLoadedCopyWithImpl<_PlatformInvoicesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformInvoicesLoaded&&const DeepCollectionEquality().equals(other._invoices, _invoices)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_invoices),hasMore,currentPage);

@override
String toString() {
  return 'BillingState.platformInvoicesLoaded(invoices: $invoices, hasMore: $hasMore, currentPage: $currentPage)';
}


}

/// @nodoc
abstract mixin class _$PlatformInvoicesLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$PlatformInvoicesLoadedCopyWith(_PlatformInvoicesLoaded value, $Res Function(_PlatformInvoicesLoaded) _then) = __$PlatformInvoicesLoadedCopyWithImpl;
@useResult
$Res call({
 List<AdminInvoice> invoices, bool hasMore, int currentPage
});




}
/// @nodoc
class __$PlatformInvoicesLoadedCopyWithImpl<$Res>
    implements _$PlatformInvoicesLoadedCopyWith<$Res> {
  __$PlatformInvoicesLoadedCopyWithImpl(this._self, this._then);

  final _PlatformInvoicesLoaded _self;
  final $Res Function(_PlatformInvoicesLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoices = null,Object? hasMore = null,Object? currentPage = null,}) {
  return _then(_PlatformInvoicesLoaded(
invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<AdminInvoice>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _CompanyInvoicesLoaded implements BillingState {
  const _CompanyInvoicesLoaded({required this.companyId, required final  List<AdminInvoice> invoices, required this.hasMore, required this.currentPage}): _invoices = invoices;
  

 final  String companyId;
 final  List<AdminInvoice> _invoices;
 List<AdminInvoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

 final  bool hasMore;
 final  int currentPage;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanyInvoicesLoadedCopyWith<_CompanyInvoicesLoaded> get copyWith => __$CompanyInvoicesLoadedCopyWithImpl<_CompanyInvoicesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanyInvoicesLoaded&&(identical(other.companyId, companyId) || other.companyId == companyId)&&const DeepCollectionEquality().equals(other._invoices, _invoices)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage));
}


@override
int get hashCode => Object.hash(runtimeType,companyId,const DeepCollectionEquality().hash(_invoices),hasMore,currentPage);

@override
String toString() {
  return 'BillingState.companyInvoicesLoaded(companyId: $companyId, invoices: $invoices, hasMore: $hasMore, currentPage: $currentPage)';
}


}

/// @nodoc
abstract mixin class _$CompanyInvoicesLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$CompanyInvoicesLoadedCopyWith(_CompanyInvoicesLoaded value, $Res Function(_CompanyInvoicesLoaded) _then) = __$CompanyInvoicesLoadedCopyWithImpl;
@useResult
$Res call({
 String companyId, List<AdminInvoice> invoices, bool hasMore, int currentPage
});




}
/// @nodoc
class __$CompanyInvoicesLoadedCopyWithImpl<$Res>
    implements _$CompanyInvoicesLoadedCopyWith<$Res> {
  __$CompanyInvoicesLoadedCopyWithImpl(this._self, this._then);

  final _CompanyInvoicesLoaded _self;
  final $Res Function(_CompanyInvoicesLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companyId = null,Object? invoices = null,Object? hasMore = null,Object? currentPage = null,}) {
  return _then(_CompanyInvoicesLoaded(
companyId: null == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String,invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<AdminInvoice>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _InvoiceGenerated implements BillingState {
  const _InvoiceGenerated({required this.invoice, required this.message});
  

 final  BillingEntity invoice;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceGeneratedCopyWith<_InvoiceGenerated> get copyWith => __$InvoiceGeneratedCopyWithImpl<_InvoiceGenerated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceGenerated&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,invoice,message);

@override
String toString() {
  return 'BillingState.invoiceGenerated(invoice: $invoice, message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvoiceGeneratedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$InvoiceGeneratedCopyWith(_InvoiceGenerated value, $Res Function(_InvoiceGenerated) _then) = __$InvoiceGeneratedCopyWithImpl;
@useResult
$Res call({
 BillingEntity invoice, String message
});


$BillingEntityCopyWith<$Res> get invoice;

}
/// @nodoc
class __$InvoiceGeneratedCopyWithImpl<$Res>
    implements _$InvoiceGeneratedCopyWith<$Res> {
  __$InvoiceGeneratedCopyWithImpl(this._self, this._then);

  final _InvoiceGenerated _self;
  final $Res Function(_InvoiceGenerated) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoice = null,Object? message = null,}) {
  return _then(_InvoiceGenerated(
invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as BillingEntity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingEntityCopyWith<$Res> get invoice {
  
  return $BillingEntityCopyWith<$Res>(_self.invoice, (value) {
    return _then(_self.copyWith(invoice: value));
  });
}
}

/// @nodoc


class _BulkInvoicesGenerated implements BillingState {
  const _BulkInvoicesGenerated({required final  List<BillingEntity> invoices, required this.message, required this.failedCount}): _invoices = invoices;
  

 final  List<BillingEntity> _invoices;
 List<BillingEntity> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}

 final  String message;
 final  int failedCount;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkInvoicesGeneratedCopyWith<_BulkInvoicesGenerated> get copyWith => __$BulkInvoicesGeneratedCopyWithImpl<_BulkInvoicesGenerated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkInvoicesGenerated&&const DeepCollectionEquality().equals(other._invoices, _invoices)&&(identical(other.message, message) || other.message == message)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_invoices),message,failedCount);

@override
String toString() {
  return 'BillingState.bulkInvoicesGenerated(invoices: $invoices, message: $message, failedCount: $failedCount)';
}


}

/// @nodoc
abstract mixin class _$BulkInvoicesGeneratedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$BulkInvoicesGeneratedCopyWith(_BulkInvoicesGenerated value, $Res Function(_BulkInvoicesGenerated) _then) = __$BulkInvoicesGeneratedCopyWithImpl;
@useResult
$Res call({
 List<BillingEntity> invoices, String message, int failedCount
});




}
/// @nodoc
class __$BulkInvoicesGeneratedCopyWithImpl<$Res>
    implements _$BulkInvoicesGeneratedCopyWith<$Res> {
  __$BulkInvoicesGeneratedCopyWithImpl(this._self, this._then);

  final _BulkInvoicesGenerated _self;
  final $Res Function(_BulkInvoicesGenerated) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoices = null,Object? message = null,Object? failedCount = null,}) {
  return _then(_BulkInvoicesGenerated(
invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<BillingEntity>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _PaymentProcessed implements BillingState {
  const _PaymentProcessed({required this.payment, required this.message});
  

 final  BillingEntity payment;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentProcessedCopyWith<_PaymentProcessed> get copyWith => __$PaymentProcessedCopyWithImpl<_PaymentProcessed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentProcessed&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,payment,message);

@override
String toString() {
  return 'BillingState.paymentProcessed(payment: $payment, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PaymentProcessedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$PaymentProcessedCopyWith(_PaymentProcessed value, $Res Function(_PaymentProcessed) _then) = __$PaymentProcessedCopyWithImpl;
@useResult
$Res call({
 BillingEntity payment, String message
});


$BillingEntityCopyWith<$Res> get payment;

}
/// @nodoc
class __$PaymentProcessedCopyWithImpl<$Res>
    implements _$PaymentProcessedCopyWith<$Res> {
  __$PaymentProcessedCopyWithImpl(this._self, this._then);

  final _PaymentProcessed _self;
  final $Res Function(_PaymentProcessed) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? message = null,}) {
  return _then(_PaymentProcessed(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as BillingEntity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingEntityCopyWith<$Res> get payment {
  
  return $BillingEntityCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

/// @nodoc


class _PartialPaymentProcessed implements BillingState {
  const _PartialPaymentProcessed({required this.payment, required this.message});
  

 final  BillingEntity payment;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartialPaymentProcessedCopyWith<_PartialPaymentProcessed> get copyWith => __$PartialPaymentProcessedCopyWithImpl<_PartialPaymentProcessed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartialPaymentProcessed&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,payment,message);

@override
String toString() {
  return 'BillingState.partialPaymentProcessed(payment: $payment, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PartialPaymentProcessedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$PartialPaymentProcessedCopyWith(_PartialPaymentProcessed value, $Res Function(_PartialPaymentProcessed) _then) = __$PartialPaymentProcessedCopyWithImpl;
@useResult
$Res call({
 BillingEntity payment, String message
});


$BillingEntityCopyWith<$Res> get payment;

}
/// @nodoc
class __$PartialPaymentProcessedCopyWithImpl<$Res>
    implements _$PartialPaymentProcessedCopyWith<$Res> {
  __$PartialPaymentProcessedCopyWithImpl(this._self, this._then);

  final _PartialPaymentProcessed _self;
  final $Res Function(_PartialPaymentProcessed) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payment = null,Object? message = null,}) {
  return _then(_PartialPaymentProcessed(
payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as BillingEntity,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillingEntityCopyWith<$Res> get payment {
  
  return $BillingEntityCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}
}

/// @nodoc


class _BulkPaymentsProcessed implements BillingState {
  const _BulkPaymentsProcessed({required final  List<BillingEntity> payments, required this.message, required this.failedCount}): _payments = payments;
  

 final  List<BillingEntity> _payments;
 List<BillingEntity> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}

 final  String message;
 final  int failedCount;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkPaymentsProcessedCopyWith<_BulkPaymentsProcessed> get copyWith => __$BulkPaymentsProcessedCopyWithImpl<_BulkPaymentsProcessed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkPaymentsProcessed&&const DeepCollectionEquality().equals(other._payments, _payments)&&(identical(other.message, message) || other.message == message)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_payments),message,failedCount);

@override
String toString() {
  return 'BillingState.bulkPaymentsProcessed(payments: $payments, message: $message, failedCount: $failedCount)';
}


}

/// @nodoc
abstract mixin class _$BulkPaymentsProcessedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$BulkPaymentsProcessedCopyWith(_BulkPaymentsProcessed value, $Res Function(_BulkPaymentsProcessed) _then) = __$BulkPaymentsProcessedCopyWithImpl;
@useResult
$Res call({
 List<BillingEntity> payments, String message, int failedCount
});




}
/// @nodoc
class __$BulkPaymentsProcessedCopyWithImpl<$Res>
    implements _$BulkPaymentsProcessedCopyWith<$Res> {
  __$BulkPaymentsProcessedCopyWithImpl(this._self, this._then);

  final _BulkPaymentsProcessed _self;
  final $Res Function(_BulkPaymentsProcessed) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? payments = null,Object? message = null,Object? failedCount = null,}) {
  return _then(_BulkPaymentsProcessed(
payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<BillingEntity>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _PaymentsReconciled implements BillingState {
  const _PaymentsReconciled({required this.reconciliation, required this.message});
  

 final  PaymentReconciliation reconciliation;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentsReconciledCopyWith<_PaymentsReconciled> get copyWith => __$PaymentsReconciledCopyWithImpl<_PaymentsReconciled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentsReconciled&&(identical(other.reconciliation, reconciliation) || other.reconciliation == reconciliation)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,reconciliation,message);

@override
String toString() {
  return 'BillingState.paymentsReconciled(reconciliation: $reconciliation, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PaymentsReconciledCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$PaymentsReconciledCopyWith(_PaymentsReconciled value, $Res Function(_PaymentsReconciled) _then) = __$PaymentsReconciledCopyWithImpl;
@useResult
$Res call({
 PaymentReconciliation reconciliation, String message
});


$PaymentReconciliationCopyWith<$Res> get reconciliation;

}
/// @nodoc
class __$PaymentsReconciledCopyWithImpl<$Res>
    implements _$PaymentsReconciledCopyWith<$Res> {
  __$PaymentsReconciledCopyWithImpl(this._self, this._then);

  final _PaymentsReconciled _self;
  final $Res Function(_PaymentsReconciled) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reconciliation = null,Object? message = null,}) {
  return _then(_PaymentsReconciled(
reconciliation: null == reconciliation ? _self.reconciliation : reconciliation // ignore: cast_nullable_to_non_nullable
as PaymentReconciliation,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentReconciliationCopyWith<$Res> get reconciliation {
  
  return $PaymentReconciliationCopyWith<$Res>(_self.reconciliation, (value) {
    return _then(_self.copyWith(reconciliation: value));
  });
}
}

/// @nodoc


class _ReconciliationAnalyzed implements BillingState {
  const _ReconciliationAnalyzed({required this.analysis, required this.message});
  

 final  ReconciliationAnalysis analysis;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReconciliationAnalyzedCopyWith<_ReconciliationAnalyzed> get copyWith => __$ReconciliationAnalyzedCopyWithImpl<_ReconciliationAnalyzed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReconciliationAnalyzed&&(identical(other.analysis, analysis) || other.analysis == analysis)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,analysis,message);

@override
String toString() {
  return 'BillingState.reconciliationAnalyzed(analysis: $analysis, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ReconciliationAnalyzedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$ReconciliationAnalyzedCopyWith(_ReconciliationAnalyzed value, $Res Function(_ReconciliationAnalyzed) _then) = __$ReconciliationAnalyzedCopyWithImpl;
@useResult
$Res call({
 ReconciliationAnalysis analysis, String message
});




}
/// @nodoc
class __$ReconciliationAnalyzedCopyWithImpl<$Res>
    implements _$ReconciliationAnalyzedCopyWith<$Res> {
  __$ReconciliationAnalyzedCopyWithImpl(this._self, this._then);

  final _ReconciliationAnalyzed _self;
  final $Res Function(_ReconciliationAnalyzed) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? analysis = null,Object? message = null,}) {
  return _then(_ReconciliationAnalyzed(
analysis: null == analysis ? _self.analysis : analysis // ignore: cast_nullable_to_non_nullable
as ReconciliationAnalysis,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RevenueReportGenerated implements BillingState {
  const _RevenueReportGenerated({required this.report, required this.message});
  

 final  RevenueReport report;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueReportGeneratedCopyWith<_RevenueReportGenerated> get copyWith => __$RevenueReportGeneratedCopyWithImpl<_RevenueReportGenerated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueReportGenerated&&(identical(other.report, report) || other.report == report)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,report,message);

@override
String toString() {
  return 'BillingState.revenueReportGenerated(report: $report, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RevenueReportGeneratedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$RevenueReportGeneratedCopyWith(_RevenueReportGenerated value, $Res Function(_RevenueReportGenerated) _then) = __$RevenueReportGeneratedCopyWithImpl;
@useResult
$Res call({
 RevenueReport report, String message
});


$RevenueReportCopyWith<$Res> get report;

}
/// @nodoc
class __$RevenueReportGeneratedCopyWithImpl<$Res>
    implements _$RevenueReportGeneratedCopyWith<$Res> {
  __$RevenueReportGeneratedCopyWithImpl(this._self, this._then);

  final _RevenueReportGenerated _self;
  final $Res Function(_RevenueReportGenerated) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? report = null,Object? message = null,}) {
  return _then(_RevenueReportGenerated(
report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as RevenueReport,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RevenueReportCopyWith<$Res> get report {
  
  return $RevenueReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}
}

/// @nodoc


class _FinancialDashboardLoaded implements BillingState {
  const _FinancialDashboardLoaded({required final  Map<String, dynamic> dashboardData, required this.message}): _dashboardData = dashboardData;
  

 final  Map<String, dynamic> _dashboardData;
 Map<String, dynamic> get dashboardData {
  if (_dashboardData is EqualUnmodifiableMapView) return _dashboardData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dashboardData);
}

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinancialDashboardLoadedCopyWith<_FinancialDashboardLoaded> get copyWith => __$FinancialDashboardLoadedCopyWithImpl<_FinancialDashboardLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinancialDashboardLoaded&&const DeepCollectionEquality().equals(other._dashboardData, _dashboardData)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dashboardData),message);

@override
String toString() {
  return 'BillingState.financialDashboardLoaded(dashboardData: $dashboardData, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FinancialDashboardLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$FinancialDashboardLoadedCopyWith(_FinancialDashboardLoaded value, $Res Function(_FinancialDashboardLoaded) _then) = __$FinancialDashboardLoadedCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> dashboardData, String message
});




}
/// @nodoc
class __$FinancialDashboardLoadedCopyWithImpl<$Res>
    implements _$FinancialDashboardLoadedCopyWith<$Res> {
  __$FinancialDashboardLoadedCopyWithImpl(this._self, this._then);

  final _FinancialDashboardLoaded _self;
  final $Res Function(_FinancialDashboardLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dashboardData = null,Object? message = null,}) {
  return _then(_FinancialDashboardLoaded(
dashboardData: null == dashboardData ? _self._dashboardData : dashboardData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _InvoicesExported implements BillingState {
  const _InvoicesExported({required this.exportUrl, required this.message});
  

 final  String exportUrl;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoicesExportedCopyWith<_InvoicesExported> get copyWith => __$InvoicesExportedCopyWithImpl<_InvoicesExported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoicesExported&&(identical(other.exportUrl, exportUrl) || other.exportUrl == exportUrl)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,exportUrl,message);

@override
String toString() {
  return 'BillingState.invoicesExported(exportUrl: $exportUrl, message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvoicesExportedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$InvoicesExportedCopyWith(_InvoicesExported value, $Res Function(_InvoicesExported) _then) = __$InvoicesExportedCopyWithImpl;
@useResult
$Res call({
 String exportUrl, String message
});




}
/// @nodoc
class __$InvoicesExportedCopyWithImpl<$Res>
    implements _$InvoicesExportedCopyWith<$Res> {
  __$InvoicesExportedCopyWithImpl(this._self, this._then);

  final _InvoicesExported _self;
  final $Res Function(_InvoicesExported) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exportUrl = null,Object? message = null,}) {
  return _then(_InvoicesExported(
exportUrl: null == exportUrl ? _self.exportUrl : exportUrl // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _RevenueReportExported implements BillingState {
  const _RevenueReportExported({required this.exportUrl, required this.message});
  

 final  String exportUrl;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueReportExportedCopyWith<_RevenueReportExported> get copyWith => __$RevenueReportExportedCopyWithImpl<_RevenueReportExported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueReportExported&&(identical(other.exportUrl, exportUrl) || other.exportUrl == exportUrl)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,exportUrl,message);

@override
String toString() {
  return 'BillingState.revenueReportExported(exportUrl: $exportUrl, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RevenueReportExportedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$RevenueReportExportedCopyWith(_RevenueReportExported value, $Res Function(_RevenueReportExported) _then) = __$RevenueReportExportedCopyWithImpl;
@useResult
$Res call({
 String exportUrl, String message
});




}
/// @nodoc
class __$RevenueReportExportedCopyWithImpl<$Res>
    implements _$RevenueReportExportedCopyWith<$Res> {
  __$RevenueReportExportedCopyWithImpl(this._self, this._then);

  final _RevenueReportExported _self;
  final $Res Function(_RevenueReportExported) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? exportUrl = null,Object? message = null,}) {
  return _then(_RevenueReportExported(
exportUrl: null == exportUrl ? _self.exportUrl : exportUrl // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _InvoiceStatusUpdated implements BillingState {
  const _InvoiceStatusUpdated({required this.invoice, required this.message});
  

 final  AdminInvoice invoice;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceStatusUpdatedCopyWith<_InvoiceStatusUpdated> get copyWith => __$InvoiceStatusUpdatedCopyWithImpl<_InvoiceStatusUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceStatusUpdated&&(identical(other.invoice, invoice) || other.invoice == invoice)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,invoice,message);

@override
String toString() {
  return 'BillingState.invoiceStatusUpdated(invoice: $invoice, message: $message)';
}


}

/// @nodoc
abstract mixin class _$InvoiceStatusUpdatedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$InvoiceStatusUpdatedCopyWith(_InvoiceStatusUpdated value, $Res Function(_InvoiceStatusUpdated) _then) = __$InvoiceStatusUpdatedCopyWithImpl;
@useResult
$Res call({
 AdminInvoice invoice, String message
});


$AdminInvoiceCopyWith<$Res> get invoice;

}
/// @nodoc
class __$InvoiceStatusUpdatedCopyWithImpl<$Res>
    implements _$InvoiceStatusUpdatedCopyWith<$Res> {
  __$InvoiceStatusUpdatedCopyWithImpl(this._self, this._then);

  final _InvoiceStatusUpdated _self;
  final $Res Function(_InvoiceStatusUpdated) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invoice = null,Object? message = null,}) {
  return _then(_InvoiceStatusUpdated(
invoice: null == invoice ? _self.invoice : invoice // ignore: cast_nullable_to_non_nullable
as AdminInvoice,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminInvoiceCopyWith<$Res> get invoice {
  
  return $AdminInvoiceCopyWith<$Res>(_self.invoice, (value) {
    return _then(_self.copyWith(invoice: value));
  });
}
}

/// @nodoc


class _CreditNoteCreated implements BillingState {
  const _CreditNoteCreated({required this.creditNote, required this.message});
  

 final  CreditNote creditNote;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNoteCreatedCopyWith<_CreditNoteCreated> get copyWith => __$CreditNoteCreatedCopyWithImpl<_CreditNoteCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNoteCreated&&(identical(other.creditNote, creditNote) || other.creditNote == creditNote)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,creditNote,message);

@override
String toString() {
  return 'BillingState.creditNoteCreated(creditNote: $creditNote, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CreditNoteCreatedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$CreditNoteCreatedCopyWith(_CreditNoteCreated value, $Res Function(_CreditNoteCreated) _then) = __$CreditNoteCreatedCopyWithImpl;
@useResult
$Res call({
 CreditNote creditNote, String message
});


$CreditNoteCopyWith<$Res> get creditNote;

}
/// @nodoc
class __$CreditNoteCreatedCopyWithImpl<$Res>
    implements _$CreditNoteCreatedCopyWith<$Res> {
  __$CreditNoteCreatedCopyWithImpl(this._self, this._then);

  final _CreditNoteCreated _self;
  final $Res Function(_CreditNoteCreated) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? creditNote = null,Object? message = null,}) {
  return _then(_CreditNoteCreated(
creditNote: null == creditNote ? _self.creditNote : creditNote // ignore: cast_nullable_to_non_nullable
as CreditNote,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreditNoteCopyWith<$Res> get creditNote {
  
  return $CreditNoteCopyWith<$Res>(_self.creditNote, (value) {
    return _then(_self.copyWith(creditNote: value));
  });
}
}

/// @nodoc


class _CreditNotesLoaded implements BillingState {
  const _CreditNotesLoaded({required final  List<CreditNote> creditNotes, required this.hasMore, required this.currentPage}): _creditNotes = creditNotes;
  

 final  List<CreditNote> _creditNotes;
 List<CreditNote> get creditNotes {
  if (_creditNotes is EqualUnmodifiableListView) return _creditNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_creditNotes);
}

 final  bool hasMore;
 final  int currentPage;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditNotesLoadedCopyWith<_CreditNotesLoaded> get copyWith => __$CreditNotesLoadedCopyWithImpl<_CreditNotesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditNotesLoaded&&const DeepCollectionEquality().equals(other._creditNotes, _creditNotes)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_creditNotes),hasMore,currentPage);

@override
String toString() {
  return 'BillingState.creditNotesLoaded(creditNotes: $creditNotes, hasMore: $hasMore, currentPage: $currentPage)';
}


}

/// @nodoc
abstract mixin class _$CreditNotesLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$CreditNotesLoadedCopyWith(_CreditNotesLoaded value, $Res Function(_CreditNotesLoaded) _then) = __$CreditNotesLoadedCopyWithImpl;
@useResult
$Res call({
 List<CreditNote> creditNotes, bool hasMore, int currentPage
});




}
/// @nodoc
class __$CreditNotesLoadedCopyWithImpl<$Res>
    implements _$CreditNotesLoadedCopyWith<$Res> {
  __$CreditNotesLoadedCopyWithImpl(this._self, this._then);

  final _CreditNotesLoaded _self;
  final $Res Function(_CreditNotesLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? creditNotes = null,Object? hasMore = null,Object? currentPage = null,}) {
  return _then(_CreditNotesLoaded(
creditNotes: null == creditNotes ? _self._creditNotes : creditNotes // ignore: cast_nullable_to_non_nullable
as List<CreditNote>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _CompaniesWithOverdueLoaded implements BillingState {
  const _CompaniesWithOverdueLoaded({required final  List<Company> companies, required this.message}): _companies = companies;
  

 final  List<Company> _companies;
 List<Company> get companies {
  if (_companies is EqualUnmodifiableListView) return _companies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_companies);
}

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompaniesWithOverdueLoadedCopyWith<_CompaniesWithOverdueLoaded> get copyWith => __$CompaniesWithOverdueLoadedCopyWithImpl<_CompaniesWithOverdueLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompaniesWithOverdueLoaded&&const DeepCollectionEquality().equals(other._companies, _companies)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_companies),message);

@override
String toString() {
  return 'BillingState.companiesWithOverdueLoaded(companies: $companies, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CompaniesWithOverdueLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$CompaniesWithOverdueLoadedCopyWith(_CompaniesWithOverdueLoaded value, $Res Function(_CompaniesWithOverdueLoaded) _then) = __$CompaniesWithOverdueLoadedCopyWithImpl;
@useResult
$Res call({
 List<Company> companies, String message
});




}
/// @nodoc
class __$CompaniesWithOverdueLoadedCopyWithImpl<$Res>
    implements _$CompaniesWithOverdueLoadedCopyWith<$Res> {
  __$CompaniesWithOverdueLoadedCopyWithImpl(this._self, this._then);

  final _CompaniesWithOverdueLoaded _self;
  final $Res Function(_CompaniesWithOverdueLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? companies = null,Object? message = null,}) {
  return _then(_CompaniesWithOverdueLoaded(
companies: null == companies ? _self._companies : companies // ignore: cast_nullable_to_non_nullable
as List<Company>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _PlatformRevenueSummaryLoaded implements BillingState {
  const _PlatformRevenueSummaryLoaded({required this.revenueSummary, required this.message});
  

 final  PlatformRevenueSummary revenueSummary;
 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformRevenueSummaryLoadedCopyWith<_PlatformRevenueSummaryLoaded> get copyWith => __$PlatformRevenueSummaryLoadedCopyWithImpl<_PlatformRevenueSummaryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformRevenueSummaryLoaded&&(identical(other.revenueSummary, revenueSummary) || other.revenueSummary == revenueSummary)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,revenueSummary,message);

@override
String toString() {
  return 'BillingState.platformRevenueSummaryLoaded(revenueSummary: $revenueSummary, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PlatformRevenueSummaryLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$PlatformRevenueSummaryLoadedCopyWith(_PlatformRevenueSummaryLoaded value, $Res Function(_PlatformRevenueSummaryLoaded) _then) = __$PlatformRevenueSummaryLoadedCopyWithImpl;
@useResult
$Res call({
 PlatformRevenueSummary revenueSummary, String message
});


$PlatformRevenueSummaryCopyWith<$Res> get revenueSummary;

}
/// @nodoc
class __$PlatformRevenueSummaryLoadedCopyWithImpl<$Res>
    implements _$PlatformRevenueSummaryLoadedCopyWith<$Res> {
  __$PlatformRevenueSummaryLoadedCopyWithImpl(this._self, this._then);

  final _PlatformRevenueSummaryLoaded _self;
  final $Res Function(_PlatformRevenueSummaryLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? revenueSummary = null,Object? message = null,}) {
  return _then(_PlatformRevenueSummaryLoaded(
revenueSummary: null == revenueSummary ? _self.revenueSummary : revenueSummary // ignore: cast_nullable_to_non_nullable
as PlatformRevenueSummary,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlatformRevenueSummaryCopyWith<$Res> get revenueSummary {
  
  return $PlatformRevenueSummaryCopyWith<$Res>(_self.revenueSummary, (value) {
    return _then(_self.copyWith(revenueSummary: value));
  });
}
}

/// @nodoc


class _RevenueByCompanyLoaded implements BillingState {
  const _RevenueByCompanyLoaded({required final  List<CompanyRevenueSummary> revenueByCompany, required this.message}): _revenueByCompany = revenueByCompany;
  

 final  List<CompanyRevenueSummary> _revenueByCompany;
 List<CompanyRevenueSummary> get revenueByCompany {
  if (_revenueByCompany is EqualUnmodifiableListView) return _revenueByCompany;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_revenueByCompany);
}

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueByCompanyLoadedCopyWith<_RevenueByCompanyLoaded> get copyWith => __$RevenueByCompanyLoadedCopyWithImpl<_RevenueByCompanyLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueByCompanyLoaded&&const DeepCollectionEquality().equals(other._revenueByCompany, _revenueByCompany)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_revenueByCompany),message);

@override
String toString() {
  return 'BillingState.revenueByCompanyLoaded(revenueByCompany: $revenueByCompany, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RevenueByCompanyLoadedCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$RevenueByCompanyLoadedCopyWith(_RevenueByCompanyLoaded value, $Res Function(_RevenueByCompanyLoaded) _then) = __$RevenueByCompanyLoadedCopyWithImpl;
@useResult
$Res call({
 List<CompanyRevenueSummary> revenueByCompany, String message
});




}
/// @nodoc
class __$RevenueByCompanyLoadedCopyWithImpl<$Res>
    implements _$RevenueByCompanyLoadedCopyWith<$Res> {
  __$RevenueByCompanyLoadedCopyWithImpl(this._self, this._then);

  final _RevenueByCompanyLoaded _self;
  final $Res Function(_RevenueByCompanyLoaded) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? revenueByCompany = null,Object? message = null,}) {
  return _then(_RevenueByCompanyLoaded(
revenueByCompany: null == revenueByCompany ? _self._revenueByCompany : revenueByCompany // ignore: cast_nullable_to_non_nullable
as List<CompanyRevenueSummary>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Success implements BillingState {
  const _Success({required this.message});
  

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BillingState.success(message: $message)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Success(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements BillingState {
  const _Error({required this.message, required this.error});
  

 final  String message;
 final  Failure error;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,message,error);

@override
String toString() {
  return 'BillingState.error(message: $message, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message, Failure error
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc


class _Empty implements BillingState {
  const _Empty({required this.message});
  

 final  String message;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmptyCopyWith<_Empty> get copyWith => __$EmptyCopyWithImpl<_Empty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Empty&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BillingState.empty(message: $message)';
}


}

/// @nodoc
abstract mixin class _$EmptyCopyWith<$Res> implements $BillingStateCopyWith<$Res> {
  factory _$EmptyCopyWith(_Empty value, $Res Function(_Empty) _then) = __$EmptyCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$EmptyCopyWithImpl<$Res>
    implements _$EmptyCopyWith<$Res> {
  __$EmptyCopyWithImpl(this._self, this._then);

  final _Empty _self;
  final $Res Function(_Empty) _then;

/// Create a copy of BillingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Empty(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

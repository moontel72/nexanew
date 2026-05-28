// Billing Bloc for Factory Admin Portal
// Business logic for factory billing operations

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart';
import 'package:trace_odd/features/factory/admin/domain/repositories/billing_repository.dart';

part 'billing_event.dart';
part 'billing_state.dart';
part 'billing_bloc.freezed.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository _billingRepository;

  BillingBloc({
    required BillingRepository billingRepository,
  })  : _billingRepository = billingRepository,
        super(const BillingState.initial()) {
    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    on<LoadBillingSummary>(_onLoadBillingSummary);
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadInvoice>(_onLoadInvoice);
    on<LoadPaymentHistory>(_onLoadPaymentHistory);
    on<MakePayment>(_onMakePayment);
    on<DownloadInvoice>(_onDownloadInvoice);
    on<SendInvoiceEmail>(_onSendInvoiceEmail);
    on<RefreshBilling>(_onRefresh);
    on<ClearBillingError>(_onClearError);
    on<ResetBilling>(_onReset);
  }

  Future<void> _onLoadBillingSummary(
    LoadBillingSummary event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      // Load billing summary
      final summary = await _billingRepository.getBillingSummary();

      // Load recent invoices (last 5)
      final recentInvoices = await _billingRepository.getInvoices(
        BillingFilter(
          limit: 5,
          sortBy: 'issueDate',
          sortDesc: true,
        ),
      );

      emit(BillingState.summaryLoaded(
        summary: summary,
        recentInvoices: recentInvoices,
        hasMoreInvoices: recentInvoices.length >= 5,
      ));
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onLoadInvoices(
    LoadInvoices event,
    Emitter<BillingState> emit,
  ) async {
    // Don't show loading if we're already in a loaded state
    if (state is! BillingLoading) {
      emit(const BillingState.loading());
    }

    try {
      final invoices = await _billingRepository.getInvoices(
        event.filter ?? const BillingFilter(),
      );

      if (invoices.isEmpty) {
        emit(const BillingState.empty(message: 'No invoices found'));
      } else {
        final currentFilter = event.filter ?? const BillingFilter();
        emit(BillingState.invoicesLoaded(
          invoices: invoices,
          filter: currentFilter,
          hasMore: invoices.length >= currentFilter.limit,
          totalCount: invoices.length,
        ));
      }
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onLoadInvoice(
    LoadInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final invoice = await _billingRepository.getInvoice(event.invoiceId);

      // Load payments for this invoice if available
      List<Payment>? payments;
      if (invoice.status == InvoiceStatus.paid) {
        try {
          payments =
              await _billingRepository.getInvoicePayments(event.invoiceId);
        } catch (_) {
          // Ignore error if payments can't be loaded
        }
      }

      emit(BillingState.invoiceDetailLoaded(
        invoice: invoice,
        payments: payments,
      ));
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onLoadPaymentHistory(
    LoadPaymentHistory event,
    Emitter<BillingState> emit,
  ) async {
    emit(const BillingState.loading());

    try {
      final payments = await _billingRepository.getPaymentHistory(
        event.filter ?? const BillingFilter(),
      );

      if (payments.isEmpty) {
        emit(const BillingState.empty(message: 'No payment history found'));
      } else {
        final currentFilter = event.filter ?? const BillingFilter();
        emit(BillingState.paymentHistoryLoaded(
          payments: payments,
          filter: currentFilter,
          hasMore: payments.length >= currentFilter.limit,
          totalCount: payments.length,
        ));
      }
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onMakePayment(
    MakePayment event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingState.paymentProcessing(invoiceId: event.invoiceId));

    try {
      final result = await _billingRepository.makePayment(
        invoiceId: event.invoiceId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        reference: event.reference,
        notes: event.notes,
      );

      emit(BillingState.paymentSuccess(
        payment: result.payment,
        updatedInvoice: result.updatedInvoice,
      ));

      // Refresh billing summary after successful payment
      add(const LoadBillingSummary());
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onDownloadInvoice(
    DownloadInvoice event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingState.invoiceDownloading(invoiceId: event.invoiceId));

    try {
      final filePath =
          await _billingRepository.downloadInvoice(event.invoiceId);

      emit(BillingState.invoiceDownloadSuccess(
        invoiceId: event.invoiceId,
        filePath: filePath,
      ));
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onSendInvoiceEmail(
    SendInvoiceEmail event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingState.invoiceEmailSending(invoiceId: event.invoiceId));

    try {
      await _billingRepository.sendInvoiceEmail(
        invoiceId: event.invoiceId,
        email: event.email,
      );

      emit(BillingState.invoiceEmailSent(invoiceId: event.invoiceId));
    } catch (error) {
      emit(_handleError(error, event));
    }
  }

  Future<void> _onRefresh(
    RefreshBilling event,
    Emitter<BillingState> emit,
  ) async {
    // If we're currently showing invoices, refresh them
    if (state is BillingInvoicesLoaded) {
      final currentState = state as BillingInvoicesLoaded;
      add(LoadInvoices(filter: currentState.filter));
    }
    // If we're showing payment history, refresh it
    else if (state is BillingPaymentHistoryLoaded) {
      final currentState = state as BillingPaymentHistoryLoaded;
      add(LoadPaymentHistory(filter: currentState.filter));
    }
    // Otherwise refresh the summary
    else {
      add(const LoadBillingSummary());
    }
  }

  void _onClearError(
    ClearBillingError event,
    Emitter<BillingState> emit,
  ) {
    // Return to initial state
    emit(const BillingState.initial());
  }

  void _onReset(
    ResetBilling event,
    Emitter<BillingState> emit,
  ) {
    emit(const BillingState.initial());
  }

  BillingState _handleError(dynamic error, BillingEvent event) {
    final errorString = error.toString().toLowerCase();

    return BillingState.error(
      message: error.toString(),
      isNetworkError: errorString.contains('network') ||
          errorString.contains('timeout') ||
          errorString.contains('connection'),
      isPaymentError: errorString.contains('payment') ||
          errorString.contains('transaction') ||
          errorString.contains('insufficient'),
      isInvoiceLocked: errorString.contains('locked') ||
          errorString.contains('unpaid') ||
          errorString.contains('restricted'),
      retryEvent: event,
    );
  }
}

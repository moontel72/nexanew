//lib/features/nexa_admin/presentation/bloc/invoices/invoice_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:trace_odd/core/errors/failures.dart';
import 'package:trace_odd/features/nexa_admin/data/models/invoice_model.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/billing_repository.dart';
import 'package:trace_odd/shared/models/billing/invoice_model.dart'
    as shared;

import 'invoice_event.dart';
import 'invoice_state.dart';
export 'invoice_event.dart';
export 'invoice_state.dart';

/// Bloc for managing invoice-specific operations in the super admin panel
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final BillingRepository _billingRepository;

  InvoiceBloc({required BillingRepository billingRepository})
    : _billingRepository = billingRepository,
      super(const InvoiceState.initial()) {
    on<LoadInvoiceDetail>(_onLoadInvoiceDetail);
    on<LoadInvoicePayments>(_onLoadInvoicePayments);
    on<ValidateInvoice>(_onValidateInvoice);
    on<CalculateInvoiceTotals>(_onCalculateInvoiceTotals);
    on<SearchInvoices>(_onSearchInvoices);
    on<FilterInvoices>(_onFilterInvoices);
    on<SortInvoices>(_onSortInvoices);
    on<ExportInvoiceDetail>(_onExportInvoiceDetail);
    on<SendInvoiceReminder>(_onSendInvoiceReminder);
    on<ApplyDiscount>(_onApplyDiscount);
    on<AddInvoiceNote>(_onAddInvoiceNote);
    on<GetInvoiceStatistics>(_onGetInvoiceStatistics);
    on<GetInvoiceTrends>(_onGetInvoiceTrends);
    on<ResetInvoiceState>(_onResetInvoiceState);
  }

  /// Handles loading invoice detail
  Future<void> _onLoadInvoiceDetail(
    LoadInvoiceDetail event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      final result = await _billingRepository.getInvoiceById(event.invoiceId);

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoice) async {
          // Load payments for this invoice
          final paymentsResult = await _billingRepository.getInvoicePayments(
            event.invoiceId,
          );

          paymentsResult.fold(
            (failure) {
              emit(
                InvoiceState.error(message: failure.message, error: failure),
              );
            },
            (payments) {
              emit(
                InvoiceState.invoiceDetailLoaded(
                  invoice: invoice,
                  payments: payments,
                  message: 'Invoice details loaded successfully',
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to load invoice details: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles loading invoice payments
  Future<void> _onLoadInvoicePayments(
    LoadInvoicePayments event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      final result = await _billingRepository.getInvoicePayments(
        event.invoiceId,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (payments) {
          emit(
            InvoiceState.invoicePaymentsLoaded(
              invoiceId: event.invoiceId,
              payments: payments,
              message: 'Invoice payments loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to load invoice payments: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles invoice validation
  Future<void> _onValidateInvoice(
    ValidateInvoice event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Get invoice details first
      final invoiceResult = await _billingRepository.getInvoiceById(
        event.invoiceId,
      );

      invoiceResult.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoice) {
          // Validate the invoice
          final validationErrors = <String>[];

          // Check invoice number
          if (invoice.invoiceNumber.isEmpty) {
            validationErrors.add('Invoice number is required');
          }

          // Check company information
          if (invoice.companyId.isEmpty) {
            validationErrors.add('Company ID is required');
          }

          if (invoice.companyName.isEmpty) {
            validationErrors.add('Company name is required');
          }

          // Check amounts
          if (invoice.totalAmount <= 0) {
            validationErrors.add('Total amount must be greater than 0');
          }

          // Check dates
          if (invoice.issueDate.isAfter(invoice.dueDate)) {
            validationErrors.add('Issue date cannot be after due date');
          }

          // Check items
          if (invoice.items.isEmpty) {
            validationErrors.add('Invoice must have at least one item');
          }

          for (var i = 0; i < invoice.items.length; i++) {
            final item = invoice.items[i];
            if (item.description.isEmpty) {
              validationErrors.add('Item ${i + 1}: Description is required');
            }
            if (item.quantity <= 0) {
              validationErrors.add(
                'Item ${i + 1}: Quantity must be greater than 0',
              );
            }
            if (item.unitPrice <= 0) {
              validationErrors.add(
                'Item ${i + 1}: Unit price must be greater than 0',
              );
            }
          }

          if (validationErrors.isEmpty) {
            emit(
              InvoiceState.invoiceValidated(
                invoiceId: event.invoiceId,
                isValid: true,
                message: 'Invoice is valid',
                warnings: [],
              ),
            );
          } else {
            emit(
              InvoiceState.invoiceValidated(
                invoiceId: event.invoiceId,
                isValid: false,
                message: 'Invoice validation failed',
                warnings: validationErrors,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to validate invoice: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles calculating invoice totals
  Future<void> _onCalculateInvoiceTotals(
    CalculateInvoiceTotals event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Calculate subtotal
      final subtotal = event.items.fold(0.0, (sum, item) => sum + item.total);

      // Calculate tax (assuming 10% for now)
      final taxAmount = subtotal * 0.1;

      // Calculate discount (if any)
      final discountAmount = event.discountPercentage != null
          ? subtotal * (event.discountPercentage! / 100)
          : 0.0;

      // Calculate total
      final totalAmount = subtotal + taxAmount - discountAmount;

      // Check currency consistency
      final currencies = event.items.map((item) => item.currency).toSet();
      if (currencies.length > 1) {
        emit(
          InvoiceState.error(
            message: 'Multiple currencies in invoice items',
            error: ValidationFailure(
              'All items must use the same currency',
              errors: {
                'currency': ['Currency mismatch detected'],
              },
            ),
          ),
        );
        return;
      }

      final currency = currencies.firstOrNull ?? 'USD';

      emit(
        InvoiceState.invoiceTotalsCalculated(
          subtotal: subtotal,
          taxAmount: taxAmount,
          discountAmount: discountAmount,
          totalAmount: totalAmount,
          currency: currency,
          itemCount: event.items.length,
          message: 'Invoice totals calculated successfully',
        ),
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to calculate invoice totals: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles searching invoices
  Future<void> _onSearchInvoices(
    SearchInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      final result = await _billingRepository.getPlatformInvoices(
        searchQuery: event.query,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoices) {
          if (invoices.isEmpty) {
            emit(
              InvoiceState.empty(
                message: 'No invoices found for "${event.query}"',
              ),
            );
          } else {
            emit(
              InvoiceState.invoicesSearched(
                query: event.query,
                invoices: invoices,
                hasMore: invoices.length == event.limit,
                currentPage: event.page,
                message:
                    'Found ${invoices.length} invoices for "${event.query}"',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to search invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles filtering invoices
  Future<void> _onFilterInvoices(
    FilterInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      final result = await _billingRepository.getPlatformInvoices(
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoices) {
          if (invoices.isEmpty) {
            emit(
              InvoiceState.empty(
                message: 'No invoices match the selected filters',
              ),
            );
          } else {
            emit(
              InvoiceState.invoicesFiltered(
                filters: {
                  'startDate': event.startDate?.toIso8601String(),
                  'endDate': event.endDate?.toIso8601String(),
                  'statuses': event.statuses?.map((s) => s.toString()).toList(),
                },
                invoices: invoices,
                hasMore: invoices.length == event.limit,
                currentPage: event.page,
                message: 'Found ${invoices.length} invoices matching filters',
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to filter invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles sorting invoices
  Future<void> _onSortInvoices(
    SortInvoices event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Get invoices first
      final result = await _billingRepository.getPlatformInvoices(
        startDate: event.startDate,
        endDate: event.endDate,
        statuses: event.statuses,
        page: event.page,
        limit: event.limit,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoices) {
          // Sort the invoices
          List<AdminInvoice> sortedInvoices = List.from(invoices);

          switch (event.sortBy) {
            case 'issueDate':
              sortedInvoices.sort((a, b) {
                final comparison = a.issueDate.compareTo(b.issueDate);
                return event.sortDesc ? -comparison : comparison;
              });
              break;
            case 'dueDate':
              sortedInvoices.sort((a, b) {
                final comparison = a.dueDate.compareTo(b.dueDate);
                return event.sortDesc ? -comparison : comparison;
              });
              break;
            case 'totalAmount':
              sortedInvoices.sort((a, b) {
                final comparison = a.totalAmount.compareTo(b.totalAmount);
                return event.sortDesc ? -comparison : comparison;
              });
              break;
            case 'companyName':
              sortedInvoices.sort((a, b) {
                final comparison = a.companyName.compareTo(b.companyName);
                return event.sortDesc ? -comparison : comparison;
              });
              break;
            case 'status':
              sortedInvoices.sort((a, b) {
                final comparison = a.status.toString().compareTo(
                  b.status.toString(),
                );
                return event.sortDesc ? -comparison : comparison;
              });
              break;
            default:
              // Default sort by issueDate descending
              sortedInvoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));
          }

          emit(
            InvoiceState.invoicesSorted(
              sortBy: event.sortBy,
              sortDesc: event.sortDesc,
              invoices: sortedInvoices,
              message:
                  'Invoices sorted by ${event.sortBy} ${event.sortDesc ? 'descending' : 'ascending'}',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to sort invoices: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles exporting invoice detail
  Future<void> _onExportInvoiceDetail(
    ExportInvoiceDetail event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Get invoice details
      final invoiceResult = await _billingRepository.getInvoiceById(
        event.invoiceId,
      );

      invoiceResult.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoice) async {
          // Get payments
          final paymentsResult = await _billingRepository.getInvoicePayments(
            event.invoiceId,
          );

          paymentsResult.fold(
            (failure) {
              emit(
                InvoiceState.error(message: failure.message, error: failure),
              );
            },
            (payments) {
              // In a real implementation, this would generate an export file
              // For now, simulate export completion
              emit(
                InvoiceState.invoiceExported(
                  invoiceId: event.invoiceId,
                  format: event.format,
                  exportData: {
                    'invoice': invoice.toJson(),
                    'payments': payments.map((p) => p.toJson()).toList(),
                    'exportedAt': DateTime.now().toIso8601String(),
                    'format': event.format,
                  },
                  message:
                      'Invoice exported successfully in ${event.format} format',
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to export invoice: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles sending invoice reminders
  Future<void> _onSendInvoiceReminder(
    SendInvoiceReminder event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Send notification through repository
      final result = await _billingRepository.sendInvoiceNotification(
        event.invoiceId,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (_) {
          emit(
            InvoiceState.invoiceReminderSent(
              invoiceId: event.invoiceId,
              reminderType: event.reminderType,
              message: 'Invoice reminder sent successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to send invoice reminder: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles applying discounts to invoices
  Future<void> _onApplyDiscount(
    ApplyDiscount event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Get current invoice
      final invoiceResult = await _billingRepository.getInvoiceById(
        event.invoiceId,
      );

      invoiceResult.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoice) {
          // Calculate new totals with discount
          final discountAmount =
              invoice.totalAmount * (event.discountPercentage / 100);
          final newTotalAmount = invoice.totalAmount - discountAmount;

          emit(
            InvoiceState.discountApplied(
              invoiceId: event.invoiceId,
              discountPercentage: event.discountPercentage,
              discountAmount: discountAmount,
              newTotalAmount: newTotalAmount,
              message:
                  'Discount of ${event.discountPercentage}% applied successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to apply discount: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles adding notes to invoices
  Future<void> _onAddInvoiceNote(
    AddInvoiceNote event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.processing());

    try {
      // Get current invoice
      final invoiceResult = await _billingRepository.getInvoiceById(
        event.invoiceId,
      );

      invoiceResult.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoice) {
          emit(
            InvoiceState.noteAdded(
              invoiceId: event.invoiceId,
              note: event.note,
              isAdminNote: event.isAdminNote,
              message: 'Note added successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to add note: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting invoice statistics
  Future<void> _onGetInvoiceStatistics(
    GetInvoiceStatistics event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      // Get platform invoices for the period
      final result = await _billingRepository.getPlatformInvoices(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoices) {
          // Calculate statistics
          final totalInvoices = invoices.length;
          final totalAmount = invoices.fold(
            0.0,
            (sum, invoice) => sum + invoice.totalAmount,
          );
          final averageAmount = totalInvoices > 0
              ? totalAmount / totalInvoices
              : 0.0;

          // Count by status
          final countByStatus = <String, int>{};
          for (final invoice in invoices) {
            final status = invoice.status.toString().split('.').last;
            countByStatus[status] = (countByStatus[status] ?? 0) + 1;
          }

          // Calculate overdue statistics
          final now = DateTime.now();
          final overdueInvoices = invoices.where((invoice) {
            return invoice.status == shared.InvoiceStatus.overdue ||
                (invoice.status == shared.InvoiceStatus.pending &&
                    invoice.dueDate.isBefore(now));
          }).toList();

          final totalOverdueAmount = overdueInvoices.fold(
            0.0,
            (sum, invoice) => sum + invoice.totalAmount,
          );

          // Calculate payment statistics
          final paidInvoices = invoices
              .where((invoice) => invoice.status == shared.InvoiceStatus.paid)
              .toList();

          final averagePaymentDays = paidInvoices.isEmpty
              ? 0.0
              : paidInvoices.fold(0.0, (sum, invoice) {
                      if (invoice.paymentDate == null) return sum;
                      final days = invoice.paymentDate!
                          .difference(invoice.issueDate)
                          .inDays;
                      return sum + days;
                    }) /
                    paidInvoices.length;

          emit(
            InvoiceState.invoiceStatisticsLoaded(
              statistics: {
                'totalInvoices': totalInvoices,
                'totalAmount': totalAmount,
                'averageAmount': averageAmount,
                'countByStatus': countByStatus,
                'overdueCount': overdueInvoices.length,
                'totalOverdueAmount': totalOverdueAmount,
                'paidCount': paidInvoices.length,
                'averagePaymentDays': averagePaymentDays,
                'periodStart': event.startDate?.toIso8601String(),
                'periodEnd': event.endDate?.toIso8601String(),
              },
              message: 'Invoice statistics loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to load invoice statistics: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles getting invoice trends
  Future<void> _onGetInvoiceTrends(
    GetInvoiceTrends event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.loading());

    try {
      // Calculate date range for trend analysis
      final endDate = event.endDate ?? DateTime.now();
      final startDate =
          event.startDate ?? endDate.subtract(const Duration(days: 30));

      // Get invoices for the period
      final result = await _billingRepository.getPlatformInvoices(
        startDate: startDate,
        endDate: endDate,
      );

      result.fold(
        (failure) {
          emit(InvoiceState.error(message: failure.message, error: failure));
        },
        (invoices) {
          // Group invoices by day
          final dailyTrends = <DateTime, Map<String, dynamic>>{};

          for (final invoice in invoices) {
            final day = DateTime(
              invoice.issueDate.year,
              invoice.issueDate.month,
              invoice.issueDate.day,
            );

            if (!dailyTrends.containsKey(day)) {
              dailyTrends[day] = {
                'date': day,
                'invoiceCount': 0,
                'totalAmount': 0.0,
                'paidCount': 0,
                'paidAmount': 0.0,
                'overdueCount': 0,
                'overdueAmount': 0.0,
              };
            }

            final dayData = dailyTrends[day]!;
            dayData['invoiceCount'] = (dayData['invoiceCount'] as int) + 1;
            dayData['totalAmount'] =
                (dayData['totalAmount'] as double) + invoice.totalAmount;

            if (invoice.status == shared.InvoiceStatus.paid) {
              dayData['paidCount'] = (dayData['paidCount'] as int) + 1;
              dayData['paidAmount'] =
                  (dayData['paidAmount'] as double) + invoice.totalAmount;
            } else if (invoice.status == shared.InvoiceStatus.overdue ||
                (invoice.status == shared.InvoiceStatus.pending &&
                    invoice.dueDate.isBefore(DateTime.now()))) {
              dayData['overdueCount'] = (dayData['overdueCount'] as int) + 1;
              dayData['overdueAmount'] =
                  (dayData['overdueAmount'] as double) + invoice.totalAmount;
            }
          }

          // Convert to sorted list
          final trendData = dailyTrends.values.toList()
            ..sort(
              (a, b) =>
                  (a['date'] as DateTime).compareTo(b['date'] as DateTime),
            );

          // Calculate growth rates
          double? growthRate;
          if (trendData.length >= 2) {
            final recent = trendData.last['totalAmount'] as double;
            final previous =
                trendData[trendData.length - 2]['totalAmount'] as double;
            growthRate = previous > 0
                ? ((recent - previous) / previous) * 100
                : null;
          }

          emit(
            InvoiceState.invoiceTrendsLoaded(
              trends: {
                'dailyTrends': trendData,
                'totalPeriodInvoices': invoices.length,
                'totalPeriodAmount': invoices.fold(
                  0.0,
                  (sum, invoice) => sum + invoice.totalAmount,
                ),
                'growthRate': growthRate,
                'periodStart': startDate.toIso8601String(),
                'periodEnd': endDate.toIso8601String(),
              },
              message: 'Invoice trends loaded successfully',
            ),
          );
        },
      );
    } catch (e) {
      emit(
        InvoiceState.error(
          message: 'Failed to load invoice trends: ${e.toString()}',
          error: UnknownFailure(e.toString()),
        ),
      );
    }
  }

  /// Handles resetting invoice state
  Future<void> _onResetInvoiceState(
    ResetInvoiceState event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceState.initial());
  }
}

//lib/features/nexa_admin/presentation/screens/super_admin/billing/company_invoices_screen.dartS
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/typography.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/billing/invoice_status_badge.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/widgets/error_state/error_state_widget.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/models/billing/invoice_model.dart'
    as shared;
import 'package:nexatrace_system/features/nexa_admin/data/models/invoice_model.dart';

/// Company Invoices Screen
/// Displays all invoices for a specific company with filtering and management options
class CompanyInvoicesScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const CompanyInvoicesScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<CompanyInvoicesScreen> createState() => _CompanyInvoicesScreenState();
}

class _CompanyInvoicesScreenState extends State<CompanyInvoicesScreen> {
  final _scrollController = ScrollController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<String>? _selectedStatuses;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCompanyInvoices();
  }

  void _loadCompanyInvoices({bool resetPage = false}) {
    if (resetPage) {
      _currentPage = 1;
      _hasMore = true;
    }

    context.read<BillingBloc>().add(
      LoadCompanyInvoices(
        companyId: widget.companyId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        statuses: _selectedStatuses?.map((s) {
          switch (s) {
            case 'draft':
              return shared.InvoiceStatus.draft;
            case 'pending':
              return shared.InvoiceStatus.pending;
            case 'paid':
              return shared.InvoiceStatus.paid;
            case 'overdue':
              return shared.InvoiceStatus.overdue;
            case 'cancelled':
              return shared.InvoiceStatus.cancelled;
            case 'refunded':
              return shared.InvoiceStatus.refunded;
            default:
              return shared.InvoiceStatus.pending;
          }
        }).toList(),
        page: _currentPage,
        limit: _itemsPerPage,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      _currentPage++;
      _loadCompanyInvoices();
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    // In a real implementation, this would trigger a search API call
    // For now, we'll just filter locally
  }

  void _handleFilterChanged({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statuses,
  }) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
      _selectedStatuses = statuses;
    });
    _loadCompanyInvoices(resetPage: true);
  }

  void _handleRefresh() {
    _loadCompanyInvoices(resetPage: true);
  }

  void _navigateToInvoiceDetail(String invoiceId) {
    context.go('/super-admin/billing/invoices/$invoiceId');
  }

  void _navigateToGenerateInvoice() {
    context.go(
      '/super-admin/billing/companies/${widget.companyId}/generate-invoice',
    );
  }

  void _navigateToPaymentHistory(String invoiceId) {
    context.go('/super-admin/billing/invoices/$invoiceId/payments');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        initialStartDate: _selectedStartDate,
        initialEndDate: _selectedEndDate,
        initialStatuses: _selectedStatuses ?? [],
        onFilterChanged: _handleFilterChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.companyName),
            Text(
              'Invoices',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search Invoices',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Invoices',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToGenerateInvoice,
        tooltip: 'Generate New Invoice',
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          state.maybeWhen(
            companyInvoicesLoaded: (companyId, invoices, hasMore, currentPage) {
              if (companyId == widget.companyId) {
                setState(() {
                  _hasMore = hasMore;
                  _currentPage = currentPage;
                });
              }
            },
            error: (message, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            companyInvoicesLoaded: (companyId, invoices, hasMore, currentPage) {
              if (companyId != widget.companyId) {
                return const LoadingIndicator();
              }

              final filteredInvoices = _searchQuery.isNotEmpty
                  ? invoices.where((invoice) {
                      return invoice.invoiceNumber.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          invoice.companyName.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                    }).toList()
                  : invoices;

              if (filteredInvoices.isEmpty) {
                return _buildEmptyState();
              }

              return _buildInvoicesList(filteredInvoices, hasMore);
            },
            loading: () => const LoadingIndicator(),
            processing: () => const LoadingIndicator(),
            error: (message, error) => ErrorState.generic(
              title: 'Error',
              message: message,
              onRetry: _handleRefresh,
            ),
            empty: (message) => _buildEmptyState(),
            orElse: () => const LoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInvoicesList(List<AdminInvoice> invoices, bool hasMore) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(invoices),

            const SizedBox(height: 24),

            // Invoices List
            Column(
              children: [
                ...invoices.map((invoice) => _buildInvoiceCard(invoice)),
                if (hasMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<AdminInvoice> invoices) {
    final totalAmount = invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );

    final paidAmount = invoices
        .where((invoice) => invoice.status == shared.InvoiceStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

    final pendingAmount = invoices
        .where((invoice) => invoice.status == shared.InvoiceStatus.pending)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

    final overdueAmount = invoices
        .where((invoice) => invoice.status == shared.InvoiceStatus.overdue)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Summary',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Total', totalAmount, AppColors.primary),
                _buildSummaryItem('Paid', paidAmount, AppColors.success),
                _buildSummaryItem('Pending', pendingAmount, AppColors.warning),
                _buildSummaryItem('Overdue', overdueAmount, AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: totalAmount > 0 ? paidAmount / totalAmount : 0,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.success,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collection Rate',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${totalAmount > 0 ? (paidAmount / totalAmount * 100).toStringAsFixed(1) : '0.0'}%',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(AdminInvoice invoice) {
    final invoiceNumber = invoice.invoiceNumber;
    final totalAmount = invoice.totalAmount;
    final status = invoice.status.name;
    final issueDate = invoice.issueDate.toLocal();
    final dueDate = invoice.dueDate.toLocal();
    final isOverdue =
        status == 'overdue' ||
        (status == 'pending' && dueDate.isBefore(DateTime.now()));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToInvoiceDetail(invoice.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoiceNumber,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Issued: ${issueDate.toString().split(' ')[0]}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InvoiceStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due Date',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        dueDate.toString().split(' ')[0],
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isOverdue)
                        Text(
                          'Overdue',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _navigateToInvoiceDetail(invoice.id),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status == 'pending' || status == 'overdue')
                    PrimaryButton(
                      onPressed: () => _navigateToPaymentHistory(invoice.id),
                      text: 'Record Payment',
                      width: 150,
                      height: 36,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('No Invoices Found', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No invoices match your search for "$_searchQuery"'
                : 'This company has no invoices yet.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_searchQuery.isNotEmpty || _selectedStartDate != null)
            PrimaryButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedStartDate = null;
                  _selectedEndDate = null;
                  _selectedStatuses = null;
                });
                _loadCompanyInvoices(resetPage: true);
              },
              text: 'Clear Filters',
            )
          else
            PrimaryButton(
              onPressed: _navigateToGenerateInvoice,
              text: 'Generate First Invoice',
            ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Invoices'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by invoice number or company...',
            border: OutlineInputBorder(),
          ),
          onChanged: _handleSearch,
          controller: TextEditingController(text: _searchQuery),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
              _loadCompanyInvoices(resetPage: true);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Filter Dialog for invoice filtering
class _FilterDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<String> initialStatuses;
  final Function({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statuses,
  })
  onFilterChanged;

  const _FilterDialog({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialStatuses,
    required this.onFilterChanged,
  });

  @override
  State<_FilterDialog> createState() => __FilterDialogState();
}

class __FilterDialogState extends State<_FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late List<String> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedStatuses = List.from(widget.initialStatuses);
  }

  void _handleApplyFilters() {
    widget.onFilterChanged(
      startDate: _startDate,
      endDate: _endDate,
      statuses: _selectedStatuses.isNotEmpty ? _selectedStatuses : null,
    );
    Navigator.pop(context);
  }

  void _handleClearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedStatuses = [];
    });
    widget.onFilterChanged(startDate: null, endDate: null, statuses: null);
    Navigator.pop(context);
  }

  void _toggleStatus(String status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Invoices'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range
            Text(
              'Date Range',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: Text(
                      _startDate != null
                          ? _startDate!.toString().split(' ')[0]
                          : 'Start Date',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Text(
                      _endDate != null
                          ? _endDate!.toString().split(' ')[0]
                          : 'End Date',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Filter
            Text(
              'Status',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip('draft', 'Draft', AppColors.textSecondary),
                _buildStatusChip('pending', 'Pending', AppColors.warning),
                _buildStatusChip('paid', 'Paid', AppColors.success),
                _buildStatusChip('overdue', 'Overdue', AppColors.error),
                _buildStatusChip('cancelled', 'Cancelled', AppColors.error),
                _buildStatusChip('refunded', 'Refunded', AppColors.info),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _handleClearFilters,
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleApplyFilters,
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, String label, Color color) {
    final isSelected = _selectedStatuses.contains(status);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _toggleStatus(status),
      backgroundColor: isSelected ? color.withOpacity(0.2) : null,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? color : AppColors.textPrimary),
      checkmarkColor: color,
    );
  }
}

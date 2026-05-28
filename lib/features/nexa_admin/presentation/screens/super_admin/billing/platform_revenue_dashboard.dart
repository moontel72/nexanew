import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/typography.dart';
import 'package:trace_odd/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:trace_odd/features/nexa_admin/presentation/widgets/billing/revenue_chart_widget.dart';
import 'package:trace_odd/shared/widgets/cards/dashboard_card.dart';
import 'package:trace_odd/shared/widgets/loading/loading_indicator.dart';
import 'package:trace_odd/shared/widgets/error_state/error_state_widget.dart';

/// Platform Revenue Dashboard Screen
/// Displays overall platform revenue metrics and trends
class PlatformRevenueDashboard extends StatefulWidget {
  const PlatformRevenueDashboard({super.key});

  @override
  State<PlatformRevenueDashboard> createState() =>
      _PlatformRevenueDashboardState();
}

class _PlatformRevenueDashboardState extends State<PlatformRevenueDashboard> {
  final _scrollController = ScrollController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<BillingBloc>().add(
      GetFinancialDashboardData(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      ),
    );
  }

  void _handleDateRangeChanged(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _selectedStartDate = startDate;
      _selectedEndDate = endDate;
    });
    _loadDashboardData();
  }

  void _handleRefresh() {
    _loadDashboardData();
  }

  void _navigateToCompanyInvoices(String companyId) {
    context.go('/super-admin/billing/company/$companyId/invoices');
  }

  void _navigateToInvoiceDetail(String invoiceId) {
    context.push('/billing/invoices/$invoiceId');
  }

  void _navigateToRevenueReports() {
    context.go('/super-admin/billing/reports');
  }

  void _navigateToPaymentReconciliation() {
    context.go('/super-admin/billing/reconciliation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Revenue Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToRevenueReports,
            tooltip: 'Revenue Reports',
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          state.maybeWhen(
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
          return state.when(
            initial: () => const LoadingIndicator(),
            loading: () => const LoadingIndicator(),
            processing: () => const LoadingIndicator(),
            financialDashboardLoaded: (dashboardData, message) =>
                _buildDashboardContent(dashboardData),
            error: (message, error) => ErrorState.generic(
              title: 'Error',
              message: message,
              onRetry: _handleRefresh,
            ),
            empty: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text('No Revenue Data', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
            success: (message) {
              // Reload data after success operations
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadDashboardData();
              });
              return const LoadingIndicator();
            },
            invoiceGenerated: (invoice, message) => const LoadingIndicator(),
            bulkInvoicesGenerated: (invoices, message, failedCount) =>
                const LoadingIndicator(),
            paymentProcessed: (payment, message) => const LoadingIndicator(),
            partialPaymentProcessed: (payment, message) =>
                const LoadingIndicator(),
            bulkPaymentsProcessed: (payments, message, failedCount) =>
                const LoadingIndicator(),
            paymentsReconciled: (reconciliation, message) =>
                const LoadingIndicator(),
            reconciliationAnalyzed: (analysis, message) =>
                const LoadingIndicator(),
            revenueReportGenerated: (report, message) =>
                const LoadingIndicator(),
            invoicesExported: (exportUrl, message) => const LoadingIndicator(),
            revenueReportExported: (exportUrl, message) =>
                const LoadingIndicator(),
            invoiceStatusUpdated: (invoice, message) =>
                const LoadingIndicator(),
            creditNoteCreated: (creditNote, message) =>
                const LoadingIndicator(),
            creditNotesLoaded: (creditNotes, hasMore, currentPage) =>
                const LoadingIndicator(),
            companiesWithOverdueLoaded: (companies, message) =>
                const LoadingIndicator(),
            platformRevenueSummaryLoaded: (revenueSummary, message) =>
                const LoadingIndicator(),
            revenueByCompanyLoaded: (revenueByCompany, message) =>
                const LoadingIndicator(),
            platformInvoicesLoaded: (invoices, hasMore, currentPage) =>
                const LoadingIndicator(),
            companyInvoicesLoaded:
                (companyId, invoices, hasMore, currentPage) =>
                    const LoadingIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(Map<String, dynamic> dashboardData) {
    final revenueSummary = dashboardData['revenue_summary'] ?? {};
    final companiesOverdue = dashboardData['companies_overdue'] ?? 0;
    final revenueByCompany = dashboardData['revenue_by_company'] ?? [];
    final recentInvoices = dashboardData['recent_invoices'] ?? [];

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range indicator
            if (_selectedStartDate != null && _selectedEndDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedStartDate!.toLocal().toString().split(' ')[0]} - ${_selectedEndDate!.toLocal().toString().split(' ')[0]}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Revenue Overview Cards
            _buildRevenueOverviewCards(revenueSummary),

            const SizedBox(height: 24),

            // Revenue Chart
            RevenueChartWidget(
              revenueData: revenueSummary,
              periodStart: _selectedStartDate,
              periodEnd: _selectedEndDate,
            ),

            const SizedBox(height: 24),

            // Companies with Overdue Invoices
            if (companiesOverdue > 0) _buildOverdueCompaniesSection(),

            const SizedBox(height: 24),

            // Top Companies by Revenue
            if (revenueByCompany.isNotEmpty)
              _buildTopCompaniesSection(revenueByCompany),

            const SizedBox(height: 24),

            // Recent Invoices
            if (recentInvoices.isNotEmpty)
              _buildRecentInvoicesSection(recentInvoices),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewCards(Map<String, dynamic> revenueSummary) {
    final totalRevenue = revenueSummary['totalRevenue'] ?? 0.0;
    final collectedRevenue = revenueSummary['collectedRevenue'] ?? 0.0;
    final pendingRevenue = revenueSummary['pendingRevenue'] ?? 0.0;
    final overdueRevenue = revenueSummary['overdueRevenue'] ?? 0.0;
    final collectionRate = totalRevenue > 0
        ? (collectedRevenue / totalRevenue * 100)
        : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        DashboardCard(
          title: 'Total Revenue',
          value: '\$${totalRevenue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: AppColors.primary,
          trend: 12.5, // This would come from API
          trendLabel: 'vs last period',
        ),
        DashboardCard(
          title: 'Collected',
          value: '\$${collectedRevenue.toStringAsFixed(2)}',
          icon: Icons.check_circle,
          color: AppColors.success,
          subtitle: '${collectionRate.toStringAsFixed(1)}% collection rate',
        ),
        DashboardCard(
          title: 'Pending',
          value: '\$${pendingRevenue.toStringAsFixed(2)}',
          icon: Icons.pending,
          color: AppColors.warning,
          subtitle: 'Awaiting payment',
        ),
        DashboardCard(
          title: 'Overdue',
          value: '\$${overdueRevenue.toStringAsFixed(2)}',
          icon: Icons.warning,
          color: AppColors.error,
          subtitle: 'Requires follow-up',
          onTap: _navigateToPaymentReconciliation,
        ),
      ],
    );
  }

  Widget _buildOverdueCompaniesSection() {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        return state.maybeWhen(
          companiesWithOverdueLoaded: (companies, message) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Companies with Overdue Invoices',
                      style: AppTypography.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<BillingBloc>().add(
                          GetCompaniesWithOverdueInvoices(),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: companies.take(5).map((company) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              company.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(company.name),
                          subtitle: Text(company.email),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () =>
                                _navigateToCompanyInvoices(company.id),
                          ),
                          onTap: () => _navigateToCompanyInvoices(company.id),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
          orElse: () {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Loading overdue companies...',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopCompaniesSection(List<dynamic> revenueByCompany) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Companies by Revenue', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: revenueByCompany.take(5).map((companyData) {
                final companyName = companyData['companyName'] ?? 'Unknown';
                final totalRevenue = companyData['totalRevenue'] ?? 0.0;
                final paidAmount = companyData['paidAmount'] ?? 0.0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      companyName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    companyName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Total: \$${totalRevenue.toStringAsFixed(2)}',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        'Paid: \$${paidAmount.toStringAsFixed(2)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      '${((paidAmount / totalRevenue) * 100).toStringAsFixed(1)}%',
                    ),
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppColors.success),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesSection(List<dynamic> recentInvoices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Invoices', style: AppTypography.headlineSmall),
            TextButton(
              onPressed: () {
                context.go('/billing/invoices');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: recentInvoices.map((invoice) {
                final invoiceNumber = invoice['invoiceNumber'] ?? '';
                final companyName = invoice['companyName'] ?? 'Unknown';
                final totalAmount = invoice['totalAmount'] ?? 0.0;
                final status = invoice['status'] ?? 'pending';
                final dueDate = invoice['dueDate'] != null
                    ? DateTime.parse(invoice['dueDate']).toLocal()
                    : null;

                Color statusColor = AppColors.warning;
                String statusText = 'Pending';
                IconData statusIcon = Icons.pending;

                switch (status) {
                  case 'paid':
                    statusColor = AppColors.success;
                    statusText = 'Paid';
                    statusIcon = Icons.check_circle;
                    break;
                  case 'overdue':
                    statusColor = AppColors.error;
                    statusText = 'Overdue';
                    statusIcon = Icons.warning;
                    break;
                  case 'draft':
                    statusColor = AppColors.textSecondary;
                    statusText = 'Draft';
                    statusIcon = Icons.edit;
                    break;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  title: Text(
                    invoiceNumber,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(companyName, style: AppTypography.bodySmall),
                      if (dueDate != null)
                        Text(
                          'Due: ${dueDate.toString().split(' ')[0]}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: AppTypography.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToInvoiceDetail(invoice['id']),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showDateRangePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
    ).then((dateRange) {
      if (dateRange != null) {
        _handleDateRangeChanged(dateRange.start, dateRange.end);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

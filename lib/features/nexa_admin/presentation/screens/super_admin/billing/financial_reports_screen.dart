import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/data/models/revenue_report_model.dart';
import 'package:nexatrace_system/shared/widgets/buttons/primary_button.dart';
import 'package:nexatrace_system/shared/widgets/cards/info_card.dart';
import 'package:nexatrace_system/shared/widgets/cards/kpi_card.dart';
import 'package:nexatrace_system/shared/widgets/inputs/text_input.dart';
import 'package:nexatrace_system/shared/widgets/loading/loading_indicator.dart';
import 'package:nexatrace_system/shared/theme/colors.dart';
import 'package:nexatrace_system/shared/theme/text_styles.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  DateTime? _reportStartDate;
  DateTime? _reportEndDate;
  String _reportType = 'profit_loss';
  bool _isLoading = false;
  RevenueReport? _reportData;

  @override
  void initState() {
    super.initState();
    _reportStartDate = DateTime.now().subtract(const Duration(days: 30));
    _reportEndDate = DateTime.now();
  }

  void _generateReport() {
    if (_reportStartDate == null || _reportEndDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select date range')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<BillingBloc>().add(
      GenerateRevenueReport(
        type: ReportType.custom,
        periodStart: _reportStartDate!,
        periodEnd: _reportEndDate!,
      ),
    );
  }

  void _exportReport() {
    if (_reportData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No report data to export')));
      return;
    }

    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _downloadPDF() {
    if (_reportData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report data to download')),
      );
      return;
    }

    // TODO: Implement PDF download
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDF download coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _downloadPDF,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          state.maybeWhen(
            revenueReportGenerated: (reportData, message) {
              setState(() {
                _isLoading = false;
                _reportData = reportData;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            error: (message, error) {
              setState(() {
                _isLoading = false;
              });
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
            loading: () => const Center(child: LoadingIndicator()),
            orElse: () => _buildContent(context),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Controls
          InfoCard(
            title: 'Report Configuration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Type
                DropdownButtonFormField<String>(
                  initialValue: _reportType,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'profit_loss',
                      child: Text('Profit & Loss Statement'),
                    ),
                    DropdownMenuItem(
                      value: 'revenue_summary',
                      child: Text('Revenue Summary'),
                    ),
                    DropdownMenuItem(
                      value: 'tax_summary',
                      child: Text('Tax Summary'),
                    ),
                    DropdownMenuItem(
                      value: 'cash_flow',
                      child: Text('Cash Flow Statement'),
                    ),
                    DropdownMenuItem(
                      value: 'balance_sheet',
                      child: Text('Balance Sheet'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _reportType = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(isStartDate: true),
                        child: AbsorbPointer(
                          child: TextInput(
                            label: 'Start Date',
                            hint: 'Select start date',
                            controller: TextEditingController(
                              text:
                                  _reportStartDate?.toLocal().toString().split(
                                    ' ',
                                  )[0] ??
                                  '',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(isStartDate: false),
                        child: AbsorbPointer(
                          child: TextInput(
                            label: 'End Date',
                            hint: 'Select end date',
                            controller: TextEditingController(
                              text:
                                  _reportEndDate?.toLocal().toString().split(
                                    ' ',
                                  )[0] ??
                                  '',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Generate Button
                PrimaryButton(
                  text: 'Generate Report',
                  icon: Icons.analytics,
                  onPressed: _generateReport,
                  isLoading: _isLoading,
                  isEnabled: !_isLoading,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Report Summary
          if (_reportData != null) ...[
            _buildReportSummary(),
            const SizedBox(height: 16),
          ],

          // Report Data
          if (_reportData != null) _buildReportData(),
        ],
      ),
    );
  }

  Widget _buildReportSummary() {
    final totalRevenue = _reportData?.totalRevenue ?? 0.0;
    final totalExpenses = _reportData?.creditNoteAmount ?? 0.0;
    final netProfit = totalRevenue - totalExpenses;

    return Row(
      children: [
        Expanded(
          child: KPICard(
            title: 'Total Revenue',
            value: '\$${totalRevenue.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            color: AppColors.success,
            subtitle: 'Period revenue',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KPICard(
            title: 'Total Expenses',
            value: '\$${totalExpenses.toStringAsFixed(2)}',
            icon: Icons.trending_down,
            color: AppColors.error,
            subtitle: 'Period expenses',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KPICard(
            title: 'Net Profit',
            value: '\$${netProfit.toStringAsFixed(2)}',
            icon: Icons.account_balance,
            color: netProfit >= 0 ? AppColors.success : AppColors.error,
            subtitle: 'After tax & expenses',
            trend: netProfit >= 0
                ? '+${netProfit.toStringAsFixed(2)}'
                : netProfit.toStringAsFixed(2),
          ),
        ),
      ],
    );
  }

  Widget _buildReportData() {
    final reportType = _reportType;

    switch (reportType) {
      case 'profit_loss':
        return _buildProfitLossReport();
      case 'revenue_summary':
        return _buildRevenueSummary();
      case 'tax_summary':
        return _buildTaxSummary();
      case 'cash_flow':
        return _buildCashFlowReport();
      case 'balance_sheet':
        return _buildBalanceSheet();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfitLossReport() {
    final revenueByPlan = _reportData?.revenueByPlan ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Revenue by Plan',
          child: Column(
            children: revenueByPlan.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Expenses (Credit Notes)',
          child: ListTile(
            title: const Text('Credit Note Amount'),
            trailing: Text(
              '\$${(_reportData?.creditNoteAmount ?? 0.0).toStringAsFixed(2)}',
              style: TextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueSummary() {
    final revenueByPlan = _reportData?.revenueByPlan ?? {};
    final topCompanies = _reportData?.topCompaniesByRevenue ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Revenue by Plan',
          child: Column(
            children: revenueByPlan.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Top Companies by Revenue',
          child: Column(
            children: topCompanies.take(10).map<Widget>((company) {
              return ListTile(
                title: Text(company.companyName),
                trailing: Text(
                  '\$${company.totalRevenue.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxSummary() {
    final revenueByPaymentMethod = _reportData?.revenueByPaymentMethod ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Revenue by Payment Method',
          child: Column(
            children: revenueByPaymentMethod.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Invoice Statistics',
          child: Column(
            children: [
              ListTile(
                title: const Text('Total Invoices'),
                trailing: Text(
                  '${_reportData?.totalInvoices ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Paid Invoices'),
                trailing: Text(
                  '${_reportData?.paidInvoices ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Pending Invoices'),
                trailing: Text(
                  '${_reportData?.pendingInvoices ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashFlowReport() {
    final monthlyTrends = _reportData?.monthlyTrends ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Monthly Revenue Trends',
          child: Column(
            children: monthlyTrends.map<Widget>((trend) {
              return ListTile(
                title: Text('${trend.monthName} ${trend.year}'),
                subtitle: Text('Invoices: ${trend.invoiceCount}'),
                trailing: Text(
                  '\$${trend.revenue.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Cash Flow Summary',
          child: Column(
            children: [
              ListTile(
                title: const Text('Collected Revenue'),
                trailing: Text(
                  '\$${(_reportData?.collectedRevenue ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Pending Revenue'),
                trailing: Text(
                  '\$${(_reportData?.pendingRevenue ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Overdue Revenue'),
                trailing: Text(
                  '\$${(_reportData?.overdueRevenue ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSheet() {
    final topPlans = _reportData?.topPlansByRevenue ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Top Plans by Revenue',
          child: Column(
            children: topPlans.map<Widget>((plan) {
              return ListTile(
                title: Text(plan.planName),
                subtitle: Text('Subscriptions: ${plan.totalSubscriptions}'),
                trailing: Text(
                  '\$${plan.totalRevenue.toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Company Statistics',
          child: Column(
            children: [
              ListTile(
                title: const Text('Active Companies'),
                trailing: Text(
                  '${_reportData?.activeCompanies ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Companies with Overdue'),
                trailing: Text(
                  '${_reportData?.companiesWithOverdue ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Companies with Credit'),
                trailing: Text(
                  '${_reportData?.companiesWithCredit ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Payment Statistics',
          child: Column(
            children: [
              ListTile(
                title: const Text('Total Payments'),
                trailing: Text(
                  '${_reportData?.totalPayments ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Average Payment Amount'),
                trailing: Text(
                  '\$${(_reportData?.averagePaymentAmount ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Average Payment Days'),
                trailing: Text(
                  '${_reportData?.averagePaymentDays ?? 0}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _reportStartDate! : _reportEndDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _reportStartDate = selectedDate;
          if (_reportEndDate != null &&
              _reportEndDate!.isBefore(_reportStartDate!)) {
            _reportEndDate = _reportStartDate;
          }
        } else {
          _reportEndDate = selectedDate;
        }
      });
    }
  }
}

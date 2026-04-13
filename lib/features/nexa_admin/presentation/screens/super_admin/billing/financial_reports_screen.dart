import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/billing/billing_bloc.dart';
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
  Map<String, dynamic>? _reportData;

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
        startDate: _reportStartDate!,
        endDate: _reportEndDate!,
        reportType: _reportType,
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
            revenueReportGenerated: (reportData) {
              setState(() {
                _isLoading = false;
                _reportData = reportData;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report generated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            error: (failure) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
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
                      child: TextInput(
                        label: 'Start Date',
                        hintText: 'Select start date',
                        readOnly: true,
                        onTap: () => _selectDate(isStartDate: true),
                        controller: TextEditingController(
                          text:
                              _reportStartDate?.toLocal().toString().split(
                                ' ',
                              )[0] ??
                              '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextInput(
                        label: 'End Date',
                        hintText: 'Select end date',
                        readOnly: true,
                        onTap: () => _selectDate(isStartDate: false),
                        controller: TextEditingController(
                          text:
                              _reportEndDate?.toLocal().toString().split(
                                ' ',
                              )[0] ??
                              '',
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
                  onPressed: _isLoading ? null : _generateReport,
                  isLoading: _isLoading,
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
    final summary = _reportData?['summary'] ?? {};
    final totalRevenue = summary['total_revenue'] ?? 0.0;
    final totalExpenses = summary['total_expenses'] ?? 0.0;
    final netProfit = summary['net_profit'] ?? 0.0;
    final taxAmount = summary['tax_amount'] ?? 0.0;

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
    final data = _reportData?['data'] ?? {};

    switch (reportType) {
      case 'profit_loss':
        return _buildProfitLossReport(data);
      case 'revenue_summary':
        return _buildRevenueSummary(data);
      case 'tax_summary':
        return _buildTaxSummary(data);
      case 'cash_flow':
        return _buildCashFlowReport(data);
      case 'balance_sheet':
        return _buildBalanceSheet(data);
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfitLossReport(Map<String, dynamic> data) {
    final revenueItems = data['revenue_items'] ?? [];
    final expenseItems = data['expense_items'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Revenue',
          child: Column(
            children: revenueItems.map<Widget>((item) {
              return ListTile(
                title: Text(item['description'] ?? ''),
                trailing: Text(
                  '\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}',
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
          title: 'Expenses',
          child: Column(
            children: expenseItems.map<Widget>((item) {
              return ListTile(
                title: Text(item['description'] ?? ''),
                trailing: Text(
                  '\$${(item['amount'] ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueSummary(Map<String, dynamic> data) {
    final revenueByPlan = data['revenue_by_plan'] ?? {};
    final revenueByCompany = data['revenue_by_company'] ?? {};

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
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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
            children: revenueByCompany.entries.take(10).map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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

  Widget _buildTaxSummary(Map<String, dynamic> data) {
    final taxByType = data['tax_by_type'] ?? {};
    final taxByCompany = data['tax_by_company'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Tax by Type',
          child: Column(
            children: taxByType.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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
          title: 'Tax by Company',
          child: Column(
            children: taxByCompany.entries.take(10).map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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

  Widget _buildCashFlowReport(Map<String, dynamic> data) {
    final cashInflows = data['cash_inflows'] ?? {};
    final cashOutflows = data['cash_outflows'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Cash Inflows',
          child: Column(
            children: cashInflows.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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
          title: 'Cash Outflows',
          child: Column(
            children: cashOutflows.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSheet(Map<String, dynamic> data) {
    final assets = data['assets'] ?? {};
    final liabilities = data['liabilities'] ?? {};
    final equity = data['equity'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          title: 'Assets',
          child: Column(
            children: assets.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
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
          title: 'Liabilities',
          child: Column(
            children: liabilities.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Equity',
          child: Column(
            children: equity.entries.map<Widget>((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${(entry.value ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              );
            }).toList(),
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

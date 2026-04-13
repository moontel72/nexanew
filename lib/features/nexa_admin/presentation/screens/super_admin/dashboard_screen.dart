// File: lib/features/nexa_admin/presentation/screens/super_admin/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nexatrace_system/core/errors/error_handler.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/bloc/dashboard/admin_dashboard_bloc.dart';
import 'package:nexatrace_system/routes/app_router.dart';
import 'package:nexatrace_system/shared/widgets/cards/kpi_card.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/dashboard/revenue_chart.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/dashboard/company_growth_chart.dart';
import 'package:nexatrace_system/features/nexa_admin/presentation/widgets/dashboard/recent_activities_widget.dart';
import 'package:nexatrace_system/shared/models/dashboard/dashboard_models.dart';

/// Super Admin Dashboard Screen
/// Main dashboard for super administrators with KPIs, charts, and analytics
class SuperAdminDashboardScreen extends StatefulWidget {
  final bool inShell;

  const SuperAdminDashboardScreen({super.key, this.inShell = false});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(const LoadDashboardData());
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (widget.inShell) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Command Center',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: _showFilterDialog,
                          tooltip: 'Filter Dashboard',
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: _exportDashboardData,
                          tooltip: 'Export Dashboard',
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: _showNotifications,
                          tooltip: 'Notifications',
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshDashboard,
                          tooltip: 'Refresh Dashboard',
                        ),
                        ElevatedButton.icon(
                          onPressed: _showQuickActions,
                          icon: const Icon(Icons.add),
                          label: const Text('Quick Actions'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: body,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build the app bar with title and actions
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Super Admin Dashboard'),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
          tooltip: 'Filter Dashboard',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _exportDashboardData,
          tooltip: 'Export Dashboard',
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showNotifications,
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshDashboard,
          tooltip: 'Refresh Dashboard',
        ),
      ],
    );
  }

  /// Build the main body of the dashboard
  Widget _buildBody() {
    return BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
      listener: (context, state) {
        if (state is AdminDashboardError) {
          _showErrorSnackBar(state.message);
        } else if (state is AdminDashboardExportComplete) {
          _showExportSuccessSnackBar(state.filePath);
        }
      },
      builder: (context, state) {
        return _buildContentBasedOnState(state);
      },
    );
  }

  /// Build content based on current state
  Widget _buildContentBasedOnState(AdminDashboardState state) {
    if (state is AdminDashboardInitial || state is AdminDashboardLoading) {
      return _buildLoadingState();
    } else if (state is AdminDashboardRefreshing) {
      return _buildRefreshingState(state);
    } else if (state is AdminDashboardExporting) {
      return _buildExportingState(state);
    } else if (state is AdminDashboardLoaded) {
      return _buildLoadedState(state);
    } else if (state is AdminDashboardError) {
      return _buildErrorState(state);
    } else {
      return _buildLoadingState();
    }
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Gap(16),
          Text('Loading dashboard data...'),
        ],
      ),
    );
  }

  /// Build refreshing state
  Widget _buildRefreshingState(AdminDashboardRefreshing state) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshDashboardAsync,
      child: _buildDashboardContent(state.previousData),
    );
  }

  /// Build exporting state
  Widget _buildExportingState(AdminDashboardExporting state) {
    return Stack(
      children: [
        _buildDashboardContent(state.dashboardData),
        _buildExportOverlay(state.exportFormat),
      ],
    );
  }

  /// Build loaded state
  Widget _buildLoadedState(AdminDashboardLoaded state) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshDashboardAsync,
      child: _buildDashboardContent(state.dashboardData),
    );
  }

  /// Build error state
  Widget _buildErrorState(AdminDashboardError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          Gap(16.h),
          Text(
            'Error Loading Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Gap(8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Gap(24.h),
          ElevatedButton.icon(
            onPressed: _retryLoading,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
          if (state.previousData != null) ...[
            Gap(16.h),
            OutlinedButton.icon(
              onPressed: _showCachedData,
              icon: const Icon(Icons.visibility),
              label: const Text('Show Cached Data'),
            ),
          ],
        ],
      ),
    );
  }

  /// Build dashboard content with data
  Widget _buildDashboardContent(DashboardData data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            _buildWelcomeHeader(),
            Gap(24.h),

            // KPIs Section
            _buildKPIsSection(data.kpis),
            Gap(24.h),

            // Charts Section
            _buildChartsSection(data),
            Gap(24.h),

            // Recent Activities Section
            _buildRecentActivitiesSection(data.recentActivities),
            Gap(24.h),

            // Top Performing Companies Section
            _buildTopCompaniesSection(data.topPerformingCompanies),
            Gap(24.h),

            // System Health Section
            _buildSystemHealthSection(data.systemHealthMetrics),
            Gap(24.h),

            // Pending Actions Section
            _buildPendingActionsSection(data.pendingActions),
            Gap(24.h),

            // Last updated timestamp
            _buildLastUpdatedFooter(data.lastUpdated),
          ],
        ),
      ),
    );
  }

  /// Build welcome header
  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Super Admin!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Gap(4.h),
        Text(
          'Here\'s what\'s happening with your platform today',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// Build KPIs section
  Widget _buildKPIsSection(DashboardKPIs kpis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Performance Indicators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showKPIsInfo,
              tooltip: 'KPI Information',
            ),
          ],
        ),
        Gap(12.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: [
            KPICard(
              title: 'Total Companies',
              value: kpis.totalCompanies.toString(),
              icon: Icons.business,
              color: Colors.blue,
              trend: '+12%',
              onTap: () => _viewCompanies(),
            ),
            KPICard(
              title: 'Active Companies',
              value: kpis.activeCompanies.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
              trend: '+8%',
              onTap: () => _viewActiveCompanies(),
            ),
            KPICard(
              title: 'Monthly Revenue',
              value: '\$${kpis.monthlyRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.purple,
              trend: '+15%',
              onTap: () => _viewRevenueAnalytics(),
            ),
            KPICard(
              title: 'Pending Payments',
              value: '\$${kpis.pendingPayments.toStringAsFixed(2)}',
              icon: Icons.pending,
              color: Colors.orange,
              trend: '-5%',
              onTap: () => _viewPendingPayments(),
            ),
            KPICard(
              title: 'Total Codes Generated',
              value: kpis.totalCodesGenerated.toString(),
              icon: Icons.qr_code,
              color: Colors.teal,
              trend: '+25%',
              onTap: () => _viewCodeUsage(),
            ),
            KPICard(
              title: 'System Uptime',
              value: '${kpis.systemUptime.toStringAsFixed(1)}%',
              icon: Icons.cloud,
              color: Colors.indigo,
              trend: '99.9%',
              onTap: () => _viewSystemHealth(),
            ),
            KPICard(
              title: 'Open Loads',
              value: kpis.openLoads.toString(),
              icon: Icons.local_shipping,
              color: Colors.deepPurple,
              trend: '',
              onTap: () => _viewTransportMarketplace(),
            ),
            KPICard(
              title: 'Active Trips',
              value: kpis.activeTrips.toString(),
              icon: Icons.route,
              color: Colors.cyan,
              trend: '',
              onTap: () => _viewTransportMarketplace(),
            ),
            KPICard(
              title: 'Fraud Reports',
              value: kpis.pendingFraudReports.toString(),
              icon: Icons.shield,
              color: Colors.redAccent,
              trend: '',
              onTap: () => _viewFraudPrevention(),
            ),
            KPICard(
              title: 'Wallet TX (24h)',
              value: kpis.walletTransactions24h.toString(),
              icon: Icons.account_balance_wallet,
              color: Colors.blueGrey,
              trend: '',
              onTap: () => _viewTransportWallet(),
            ),
          ],
        ),
      ],
    );
  }

  /// Build charts section
  Widget _buildChartsSection(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Charts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;

            if (isNarrow) {
              return Column(
                children: [
                  RevenueChart(
                    revenueAnalytics: data.revenueAnalytics,
                    onViewDetails: () => _viewRevenueDetails(),
                  ),
                  Gap(16.h),
                  CompanyGrowthChart(
                    companyGrowthAnalytics: data.companyGrowthAnalytics,
                    onViewDetails: () => _viewCompanyGrowthDetails(),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: RevenueChart(
                    revenueAnalytics: data.revenueAnalytics,
                    onViewDetails: () => _viewRevenueDetails(),
                  ),
                ),
                Gap(16.w),
                Expanded(
                  child: CompanyGrowthChart(
                    companyGrowthAnalytics: data.companyGrowthAnalytics,
                    onViewDetails: () => _viewCompanyGrowthDetails(),
                  ),
                ),
              ],
            );
          },
        ),
        Gap(16.h),
        // Usage and subscription mini charts
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 720;

            Widget codeUsageCard() {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.data_usage,
                            color: Colors.blue,
                            size: 20.w,
                          ),
                          Gap(8.w),
                          Text(
                            'Code Usage',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Text(
                        '${data.usageAnalytics.codesGeneratedThisMonth} codes this month',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Gap(4.h),
                      Text(
                        '${data.usageAnalytics.totalCodesGenerated} total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget subscriptionsCard() {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.subscriptions,
                            color: Colors.green,
                            size: 20.w,
                          ),
                          Gap(8.w),
                          Text(
                            'Subscriptions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Text(
                        '${data.subscriptionAnalytics.activeSubscriptions} active',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Gap(4.h),
                      Text(
                        '${data.subscriptionAnalytics.expiringThisMonth} expiring',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (isNarrow) {
              return Column(
                children: [
                  codeUsageCard(),
                  Gap(16.h),
                  subscriptionsCard(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: codeUsageCard()),
                Gap(16.w),
                Expanded(child: subscriptionsCard()),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build recent activities section
  Widget _buildRecentActivitiesSection(List<RecentActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: _viewAllActivities,
              child: const Text('View All'),
            ),
          ],
        ),
        Gap(12.h),
        RecentActivitiesWidget(
          activities: activities.take(5).toList(),
          onActivityTap: (activity) => _viewActivityDetails(activity),
          onMarkAllAsRead: _markAllActivitiesAsRead,
        ),
      ],
    );
  }

  /// Build top companies section
  Widget _buildTopCompaniesSection(List<TopPerformingCompany> companies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Performing Companies',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: _viewAllCompanies,
              child: const Text('View All'),
            ),
          ],
        ),
        Gap(12.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: companies
                  .take(3)
                  .map(
                    (company) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          company.companyName[0],
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      title: Text(company.companyName),
                      subtitle: Text(
                          '${company.planType} • \$${company.revenue.toStringAsFixed(2)}'),
                      trailing: Chip(
                        label: Text(
                            '${company.usagePercentage.toStringAsFixed(1)}%'),
                        backgroundColor: company.usagePercentage > 80
                            ? Colors.green[100]
                            : company.usagePercentage > 50
                                ? Colors.orange[100]
                                : Colors.blue[100],
                      ),
                      onTap: () => _viewCompanyDetails(company),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build system health section
  Widget _buildSystemHealthSection(SystemHealthMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(12.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthMetric(
                        'Uptime',
                        '${metrics.uptimePercentage.toStringAsFixed(1)}%',
                        metrics.uptimePercentage > 99.5
                            ? Colors.green
                            : metrics.uptimePercentage > 99
                                ? Colors.orange
                                : Colors.red,
                        Icons.cloud,
                      ),
                    ),
                    Expanded(
                      child: _buildHealthMetric(
                        'Response Time',
                        '${metrics.responseTime.toStringAsFixed(0)}ms',
                        metrics.responseTime < 100
                            ? Colors.green
                            : metrics.responseTime < 300
                                ? Colors.orange
                                : Colors.red,
                        Icons.speed,
                      ),
                    ),
                  ],
                ),
                Gap(12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthMetric(
                        'CPU Usage',
                        '${metrics.cpuUsage.toStringAsFixed(1)}%',
                        metrics.cpuUsage < 60
                            ? Colors.green
                            : metrics.cpuUsage < 80
                                ? Colors.orange
                                : Colors.red,
                        Icons.memory,
                      ),
                    ),
                    Expanded(
                      child: _buildHealthMetric(
                        'Memory Usage',
                        '${metrics.memoryUsage.toStringAsFixed(1)}%',
                        metrics.memoryUsage < 70
                            ? Colors.green
                            : metrics.memoryUsage < 85
                                ? Colors.orange
                                : Colors.red,
                        Icons.storage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build a single health metric widget
  Widget _buildHealthMetric(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.w),
            Gap(8.w),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Gap(4.h),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Build pending actions section
  Widget _buildPendingActionsSection(List<PendingAction> pendingActions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: _viewAllPendingActions,
              child: const Text('View All'),
            ),
          ],
        ),
        Gap(12.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: pendingActions.isEmpty
                  ? [
                      const Center(
                        child: Text('No pending actions'),
                      ),
                    ]
                  : pendingActions
                      .take(5)
                      .map(
                        (action) => ListTile(
                          leading: Icon(
                            _getActionIcon(action.type),
                            color: _getActionColor(action.priority),
                          ),
                          title: Text(action.title),
                          subtitle: Text(action.description),
                          trailing: Chip(
                            label: Text(action.priority.name.toUpperCase()),
                            backgroundColor: _getActionColor(action.priority)
                                .withOpacity(0.2),
                          ),
                          onTap: () => _handlePendingAction(action),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build last updated footer
  Widget _buildLastUpdatedFooter(DateTime lastUpdated) {
    return Center(
      child: Text(
        'Last updated: ${_formatDateTime(lastUpdated)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
      ),
    );
  }

  /// Build export overlay
  Widget _buildExportOverlay(String exportFormat) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                Gap(16.h),
                Text('Exporting as $exportFormat...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      icon: const Icon(Icons.add),
      label: const Text('Quick Actions'),
    );
  }

  // Helper methods
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'subscription':
        return Icons.subscriptions;
      case 'support':
        return Icons.support;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(ActionPriority priority) {
    switch (priority) {
      case ActionPriority.high:
        return Colors.red;
      case ActionPriority.medium:
        return Colors.orange;
      case ActionPriority.low:
        return Colors.green;
    }
  }

  // Action methods
  void _showFilterDialog() {
    // TODO: Implement filter dialog
  }

  void _exportDashboardData() {
    context.read<AdminDashboardBloc>().add(const ExportDashboardData(format: 'pdf'));
  }

  void _showNotifications() {
    // TODO: Implement notifications
  }

  void _refreshDashboard() {
    context.read<AdminDashboardBloc>().add(const RefreshDashboardData());
  }

  Future<void> _refreshDashboardAsync() async {
    context.read<AdminDashboardBloc>().add(const RefreshDashboardData());
  }

  void _retryLoading() {
    context.read<AdminDashboardBloc>().add(const LoadDashboardData());
  }

  void _showCachedData() {
    // TODO: Implement show cached data
  }

  void _showErrorSnackBar(String message) {
    ErrorHandler.showPersistentError(
      context,
      title: 'Dashboard Error',
      message: message,
    );
  }

  void _showExportSuccessSnackBar(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Export saved to: $filePath'),
          backgroundColor: Colors.green),
    );
  }

  void _showKPIsInfo() {
    // TODO: Implement KPIs info dialog
  }

  void _viewCompanies() {
    context.read<AppRouter>().goToCompanies(context);
  }

  void _viewActiveCompanies() {
    context.read<AppRouter>().goToCompanies(context);
  }

  void _viewRevenueAnalytics() {
    context.read<AppRouter>().goToPlans(context);
  }

  void _viewPendingPayments() {
    context.read<AppRouter>().goToPlans(context);
  }

  void _viewCodeUsage() {
    context.read<AppRouter>().goToCompanies(context);
  }

  void _viewSystemHealth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Health'),
        content: const Text('System health details will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewRevenueDetails() {
    // TODO: Navigate to revenue details
  }

  void _viewCompanyGrowthDetails() {
    // TODO: Navigate to company growth details
  }

  void _viewAllActivities() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activities screen coming soon')),
    );
  }

  void _viewActivityDetails(RecentActivity activity) {
    // TODO: Show activity details
  }

  void _markAllActivitiesAsRead() {
    // TODO: Mark all activities as read
  }

  void _viewAllCompanies() {
    context.read<AppRouter>().goToCompanies(context);
  }

  void _viewCompanyDetails(TopPerformingCompany company) {
    context.read<AppRouter>().goToCompanies(context);
  }

  void _viewTransportWallet() {
    context.read<AppRouter>().goToTransportWallet(context);
  }

  void _viewTransportMarketplace() {
    context.read<AppRouter>().goToTransportMarketplace(context);
  }

  void _viewFraudPrevention() {
    context.read<AppRouter>().goToTransportFraud(context);
  }

  void _viewAllPendingActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pending actions screen coming soon')),
    );
  }

  void _handlePendingAction(PendingAction action) {
    // TODO: Handle pending action
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.apartment),
                  title: const Text('Companies'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppRouter>().goToCompanies(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Plans'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppRouter>().goToPlans(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    _refreshDashboard();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

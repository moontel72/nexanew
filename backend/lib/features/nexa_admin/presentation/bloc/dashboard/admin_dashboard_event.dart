part of 'admin_dashboard_bloc.dart';

/// Admin Dashboard Events
/// Events that trigger state changes in the Admin Dashboard BLoC
abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data
class LoadDashboardData extends AdminDashboardEvent {
  const LoadDashboardData();
}

/// Event to refresh dashboard data
class RefreshDashboardData extends AdminDashboardEvent {
  const RefreshDashboardData();
}

/// Event to filter dashboard data by date range
class FilterDashboardByDateRange extends AdminDashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FilterDashboardByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to filter dashboard data by plan type
class FilterDashboardByPlanType extends AdminDashboardEvent {
  final String? planType;

  const FilterDashboardByPlanType({this.planType});

  @override
  List<Object?> get props => [planType];
}

/// Event to filter dashboard data by company status
class FilterDashboardByCompanyStatus extends AdminDashboardEvent {
  final String? companyStatus;

  const FilterDashboardByCompanyStatus({this.companyStatus});

  @override
  List<Object?> get props => [companyStatus];
}

/// Event to filter dashboard data by industry
class FilterDashboardByIndustry extends AdminDashboardEvent {
  final String? industry;

  const FilterDashboardByIndustry({this.industry});

  @override
  List<Object?> get props => [industry];
}

/// Event to export dashboard data
class ExportDashboardData extends AdminDashboardEvent {
  final String format; // 'csv', 'pdf', 'excel'
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportDashboardData({
    this.format = 'csv',
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [format, startDate, endDate];
}

/// Event to view detailed statistics
class ViewDetailedStatistics extends AdminDashboardEvent {
  final String
  statisticType; // 'revenue', 'companies', 'usage', 'subscriptions'

  const ViewDetailedStatistics({required this.statisticType});

  @override
  List<Object?> get props => [statisticType];
}

/// Event to toggle dashboard view mode
class ToggleDashboardViewMode extends AdminDashboardEvent {
  final String viewMode; // 'overview', 'detailed', 'comparison'

  const ToggleDashboardViewMode({required this.viewMode});

  @override
  List<Object?> get props => [viewMode];
}

/// Event to load real-time updates
class LoadRealTimeUpdates extends AdminDashboardEvent {
  const LoadRealTimeUpdates();
}

/// Event to clear dashboard filters
class ClearDashboardFilters extends AdminDashboardEvent {
  const ClearDashboardFilters();
}

/// Event to load dashboard KPIs
class LoadDashboardKPIs extends AdminDashboardEvent {
  const LoadDashboardKPIs();
}

/// Event to load revenue analytics
class LoadRevenueAnalytics extends AdminDashboardEvent {
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'

  const LoadRevenueAnalytics({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event to load company growth analytics
class LoadCompanyGrowthAnalytics extends AdminDashboardEvent {
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'

  const LoadCompanyGrowthAnalytics({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event to load usage analytics
class LoadUsageAnalytics extends AdminDashboardEvent {
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'

  const LoadUsageAnalytics({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event to load subscription analytics
class LoadSubscriptionAnalytics extends AdminDashboardEvent {
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'

  const LoadSubscriptionAnalytics({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Event to load recent activities
class LoadRecentActivities extends AdminDashboardEvent {
  final int limit; // Number of activities to load

  const LoadRecentActivities({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Event to load top performing companies
class LoadTopPerformingCompanies extends AdminDashboardEvent {
  final int limit; // Number of companies to load

  const LoadTopPerformingCompanies({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}

/// Event to load plan distribution
class LoadPlanDistribution extends AdminDashboardEvent {
  const LoadPlanDistribution();
}

/// Event to load geographical distribution
class LoadGeographicalDistribution extends AdminDashboardEvent {
  const LoadGeographicalDistribution();
}

/// Event to load system health metrics
class LoadSystemHealthMetrics extends AdminDashboardEvent {
  const LoadSystemHealthMetrics();
}

/// Event to load pending actions
class LoadPendingActions extends AdminDashboardEvent {
  const LoadPendingActions();
}

/// Event to mark notification as read
class MarkNotificationAsRead extends AdminDashboardEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Event to clear all notifications
class ClearAllNotifications extends AdminDashboardEvent {
  const ClearAllNotifications();
}

/// Event to switch dashboard tab
class SwitchDashboardTab extends AdminDashboardEvent {
  final String tab; // 'overview', 'analytics', 'monitoring', 'reports'

  const SwitchDashboardTab({required this.tab});

  @override
  List<Object?> get props => [tab];
}

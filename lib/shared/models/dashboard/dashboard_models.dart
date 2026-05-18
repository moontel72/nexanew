import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final DashboardKPIs kpis;
  final List<RecentActivity> recentActivities;
  final List<TopPerformingCompany> topPerformingCompanies;
  final SystemHealthMetrics systemHealthMetrics;
  final List<PendingAction> pendingActions;
  final RevenueAnalytics revenueAnalytics;
  final CompanyGrowthAnalytics companyGrowthAnalytics;
  final UsageAnalytics usageAnalytics;
  final SubscriptionAnalytics subscriptionAnalytics;
  final DateTime lastUpdated;

  const DashboardData({
    required this.kpis,
    required this.recentActivities,
    required this.topPerformingCompanies,
    required this.systemHealthMetrics,
    required this.pendingActions,
    required this.revenueAnalytics,
    required this.companyGrowthAnalytics,
    required this.usageAnalytics,
    required this.subscriptionAnalytics,
    required this.lastUpdated,
  });

  factory DashboardData.fromApi(Map<String, dynamic> json) {
    final stats = (json['statistics'] as Map?)?.cast<String, dynamic>() ?? {};
    final recent =
        (json['recent_activities'] as List?)?.cast<Map>() ?? const [];
    final revenue = (json['revenue_data'] as List?)?.cast<Map>() ?? const [];
    final usage = (json['usage_data'] as List?)?.cast<Map>() ?? const [];
    final top = (json['top_companies'] as List?)?.cast<Map>() ?? const [];
    final health =
        (json['system_health'] as Map?)?.cast<String, dynamic>() ?? {};

    final monthlyRevenue = List<double>.generate(
      12,
      (i) => (revenue.length > i ? (revenue[i]['value'] ?? 0) : 0) is num
          ? ((revenue.length > i ? (revenue[i]['value'] ?? 0) : 0) as num)
                .toDouble()
          : 0.0,
    );

    final monthlyGrowth = List<int>.generate(
      12,
      (i) => (usage.length > i ? (usage[i]['new_companies'] ?? 0) : 0) is num
          ? ((usage.length > i ? (usage[i]['new_companies'] ?? 0) : 0) as num)
                .toInt()
          : 0,
    );

    final codesThisMonth =
        (stats['codes_generated_this_month'] as num?)?.toInt() ??
        (stats['codes_this_month'] as num?)?.toInt() ??
        0;
    final totalCodes = (stats['total_codes_generated'] as num?)?.toInt() ?? 0;

    return DashboardData(
      kpis: DashboardKPIs(
        totalCompanies: (stats['total_companies'] as num?)?.toInt() ?? 0,
        activeCompanies: (stats['active_companies'] as num?)?.toInt() ?? 0,
        verifiedCompanies: (stats['verified_companies'] as num?)?.toInt() ?? 0,
        monthlyRevenue: (stats['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
        pendingPayments: (stats['pending_payments'] as num?)?.toDouble() ?? 0.0,
        totalCodesGenerated: totalCodes,
        systemUptime:
            (health['uptime'] as num?)?.toDouble() ??
            (stats['system_uptime'] as num?)?.toDouble() ??
            0.0,
        openLoads:
            (stats['open_loads'] as num?)?.toInt() ??
            (stats['transport_open_loads'] as num?)?.toInt() ??
            0,
        activeTrips:
            (stats['active_trips'] as num?)?.toInt() ??
            (stats['transport_active_trips'] as num?)?.toInt() ??
            0,
        pendingFraudReports:
            (stats['pending_fraud_reports'] as num?)?.toInt() ??
            (stats['fraud_pending'] as num?)?.toInt() ??
            0,
        walletTransactions24h:
            (stats['wallet_transactions_24h'] as num?)?.toInt() ??
            (stats['wallet_tx_24h'] as num?)?.toInt() ??
            0,
      ),
      recentActivities: recent
          .map(
            (m) => RecentActivity(
              id: (m['id'] ?? '').toString(),
              title: (m['title'] ?? '').toString(),
              description: (m['description'] ?? '').toString(),
              timestamp:
                  DateTime.tryParse((m['timestamp'] ?? '').toString()) ??
                  DateTime.now(),
              type: (m['type'] ?? '').toString(),
            ),
          )
          .toList(),
      topPerformingCompanies: top
          .map(
            (m) => TopPerformingCompany(
              id: (m['id'] ?? '').toString(),
              companyName: (m['company_name'] ?? m['name'] ?? '').toString(),
              planType: (m['plan_type'] ?? '').toString(),
              revenue: (m['revenue'] as num?)?.toDouble() ?? 0.0,
              usagePercentage:
                  (m['usage_percentage'] as num?)?.toDouble() ?? 0.0,
            ),
          )
          .toList(),
      systemHealthMetrics: SystemHealthMetrics(
        uptimePercentage:
            (health['uptime_percentage'] as num?)?.toDouble() ??
            (health['uptime'] as num?)?.toDouble() ??
            0.0,
        responseTime: (health['response_time'] as num?)?.toDouble() ?? 0.0,
        cpuUsage: (health['cpu_usage'] as num?)?.toDouble() ?? 0.0,
        memoryUsage: (health['memory_usage'] as num?)?.toDouble() ?? 0.0,
      ),
      pendingActions: const [],
      revenueAnalytics: RevenueAnalytics(
        monthlyData: monthlyRevenue,
        total: monthlyRevenue.fold(0.0, (a, b) => a + b),
      ),
      companyGrowthAnalytics: CompanyGrowthAnalytics(
        monthlyData: monthlyGrowth,
        totalGrowth: monthlyGrowth.fold(0, (a, b) => a + b),
      ),
      usageAnalytics: UsageAnalytics(
        codesGeneratedThisMonth: codesThisMonth,
        totalCodesGenerated: totalCodes,
      ),
      subscriptionAnalytics: const SubscriptionAnalytics(
        activeSubscriptions: 0,
        expiringThisMonth: 0,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    kpis,
    recentActivities,
    topPerformingCompanies,
    systemHealthMetrics,
    pendingActions,
    revenueAnalytics,
    companyGrowthAnalytics,
    usageAnalytics,
    subscriptionAnalytics,
    lastUpdated,
  ];
}

class DashboardKPIs extends Equatable {
  final int totalCompanies;
  final int activeCompanies;
  final int verifiedCompanies;
  final double monthlyRevenue;
  final double pendingPayments;
  final int totalCodesGenerated;
  final double systemUptime;
  final int openLoads;
  final int activeTrips;
  final int pendingFraudReports;
  final int walletTransactions24h;

  const DashboardKPIs({
    required this.totalCompanies,
    required this.activeCompanies,
    this.verifiedCompanies = 0,
    required this.monthlyRevenue,
    required this.pendingPayments,
    required this.totalCodesGenerated,
    required this.systemUptime,
    required this.openLoads,
    required this.activeTrips,
    required this.pendingFraudReports,
    required this.walletTransactions24h,
  });

  @override
  List<Object?> get props => [
    totalCompanies,
    activeCompanies,
    verifiedCompanies,
    monthlyRevenue,
    pendingPayments,
    totalCodesGenerated,
    systemUptime,
    openLoads,
    activeTrips,
    pendingFraudReports,
    walletTransactions24h,
  ];
}

class RecentActivity extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, description, timestamp, type];
}

class TopPerformingCompany extends Equatable {
  final String id;
  final String companyName;
  final String planType;
  final double revenue;
  final double usagePercentage;

  const TopPerformingCompany({
    required this.id,
    required this.companyName,
    required this.planType,
    required this.revenue,
    required this.usagePercentage,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    planType,
    revenue,
    usagePercentage,
  ];
}

class SystemHealthMetrics extends Equatable {
  final double uptimePercentage;
  final double responseTime;
  final double cpuUsage;
  final double memoryUsage;

  const SystemHealthMetrics({
    required this.uptimePercentage,
    required this.responseTime,
    required this.cpuUsage,
    required this.memoryUsage,
  });

  @override
  List<Object?> get props => [
    uptimePercentage,
    responseTime,
    cpuUsage,
    memoryUsage,
  ];
}

class PendingAction extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type;
  final ActionPriority priority;

  const PendingAction({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });

  @override
  List<Object?> get props => [id, title, description, type, priority];
}

enum ActionPriority { low, medium, high }

class RevenueAnalytics extends Equatable {
  final List<double> monthlyData;
  final double total;

  const RevenueAnalytics({required this.monthlyData, required this.total});

  @override
  List<Object?> get props => [monthlyData, total];
}

class CompanyGrowthAnalytics extends Equatable {
  final List<int> monthlyData;
  final int totalGrowth;

  const CompanyGrowthAnalytics({
    required this.monthlyData,
    required this.totalGrowth,
  });

  @override
  List<Object?> get props => [monthlyData, totalGrowth];
}

class UsageAnalytics extends Equatable {
  final int codesGeneratedThisMonth;
  final int totalCodesGenerated;

  const UsageAnalytics({
    required this.codesGeneratedThisMonth,
    required this.totalCodesGenerated,
  });

  @override
  List<Object?> get props => [codesGeneratedThisMonth, totalCodesGenerated];
}

class SubscriptionAnalytics extends Equatable {
  final int activeSubscriptions;
  final int expiringThisMonth;

  const SubscriptionAnalytics({
    required this.activeSubscriptions,
    required this.expiringThisMonth,
  });

  @override
  List<Object?> get props => [activeSubscriptions, expiringThisMonth];
}

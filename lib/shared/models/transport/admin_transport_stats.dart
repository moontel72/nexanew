import 'package:equatable/equatable.dart';

class WalletAdminStats extends Equatable {
  final int totalWallets;
  final double totalBalance;
  final int transactionsLast24h;
  final int suspiciousLast24h;

  const WalletAdminStats({
    required this.totalWallets,
    required this.totalBalance,
    required this.transactionsLast24h,
    required this.suspiciousLast24h,
  });

  factory WalletAdminStats.fromApi(Map<String, dynamic> json) {
    return WalletAdminStats(
      totalWallets: (json['total_wallets'] as num?)?.toInt() ?? 0,
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      transactionsLast24h: (json['transactions_24h'] as num?)?.toInt() ?? 0,
      suspiciousLast24h: (json['suspicious_24h'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalWallets,
        totalBalance,
        transactionsLast24h,
        suspiciousLast24h,
      ];
}

class MarketplaceAdminStats extends Equatable {
  final int totalLoads;
  final int openLoads;
  final int totalBids;
  final int activeTrips;

  const MarketplaceAdminStats({
    required this.totalLoads,
    required this.openLoads,
    required this.totalBids,
    required this.activeTrips,
  });

  factory MarketplaceAdminStats.fromApi(Map<String, dynamic> json) {
    return MarketplaceAdminStats(
      totalLoads: (json['total_loads'] as num?)?.toInt() ?? 0,
      openLoads: (json['open_loads'] as num?)?.toInt() ?? 0,
      totalBids: (json['total_bids'] as num?)?.toInt() ?? 0,
      activeTrips: (json['active_trips'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalLoads, openLoads, totalBids, activeTrips];
}

class FraudAdminStats extends Equatable {
  final int pendingReports;
  final int confirmedReports;
  final int penaltiesApplied;

  const FraudAdminStats({
    required this.pendingReports,
    required this.confirmedReports,
    required this.penaltiesApplied,
  });

  factory FraudAdminStats.fromApi(Map<String, dynamic> json) {
    return FraudAdminStats(
      pendingReports: (json['pending_reports'] as num?)?.toInt() ??
          (json['pending'] as num?)?.toInt() ??
          0,
      confirmedReports: (json['confirmed_reports'] as num?)?.toInt() ??
          (json['confirmed'] as num?)?.toInt() ??
          0,
      penaltiesApplied: (json['penalties_applied'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [pendingReports, confirmedReports, penaltiesApplied];
}

class DriversAdminStats extends Equatable {
  final int totalDrivers;
  final int activeDrivers;
  final int activeTrips;
  final double totalEarningsThisMonth;

  const DriversAdminStats({
    required this.totalDrivers,
    required this.activeDrivers,
    required this.activeTrips,
    required this.totalEarningsThisMonth,
  });

  factory DriversAdminStats.fromApi(Map<String, dynamic> json) {
    return DriversAdminStats(
      totalDrivers: (json['total_drivers'] as num?)?.toInt() ?? 0,
      activeDrivers: (json['active_drivers'] as num?)?.toInt() ?? 0,
      activeTrips: (json['active_trips'] as num?)?.toInt() ?? 0,
      totalEarningsThisMonth:
          (json['earnings_this_month'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        totalDrivers,
        activeDrivers,
        activeTrips,
        totalEarningsThisMonth,
      ];
}


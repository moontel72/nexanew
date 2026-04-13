part of 'transport_admin_bloc.dart';

enum TransportAdminStatus { initial, loading, loaded, error }

class TransportAdminState extends Equatable {
  final TransportAdminStatus walletStatus;
  final WalletAdminStats? walletStats;
  final String? walletError;

  final TransportAdminStatus marketplaceStatus;
  final MarketplaceAdminStats? marketplaceStats;
  final String? marketplaceError;

  final TransportAdminStatus driversStatus;
  final DriversAdminStats? driversStats;
  final String? driversError;

  final TransportAdminStatus fraudStatus;
  final FraudAdminStats? fraudStats;
  final String? fraudError;

  const TransportAdminState({
    this.walletStatus = TransportAdminStatus.initial,
    this.walletStats,
    this.walletError,
    this.marketplaceStatus = TransportAdminStatus.initial,
    this.marketplaceStats,
    this.marketplaceError,
    this.driversStatus = TransportAdminStatus.initial,
    this.driversStats,
    this.driversError,
    this.fraudStatus = TransportAdminStatus.initial,
    this.fraudStats,
    this.fraudError,
  });

  TransportAdminState copyWith({
    TransportAdminStatus? walletStatus,
    WalletAdminStats? walletStats,
    String? walletError,
    TransportAdminStatus? marketplaceStatus,
    MarketplaceAdminStats? marketplaceStats,
    String? marketplaceError,
    TransportAdminStatus? driversStatus,
    DriversAdminStats? driversStats,
    String? driversError,
    TransportAdminStatus? fraudStatus,
    FraudAdminStats? fraudStats,
    String? fraudError,
  }) {
    return TransportAdminState(
      walletStatus: walletStatus ?? this.walletStatus,
      walletStats: walletStats ?? this.walletStats,
      walletError: walletError,
      marketplaceStatus: marketplaceStatus ?? this.marketplaceStatus,
      marketplaceStats: marketplaceStats ?? this.marketplaceStats,
      marketplaceError: marketplaceError,
      driversStatus: driversStatus ?? this.driversStatus,
      driversStats: driversStats ?? this.driversStats,
      driversError: driversError,
      fraudStatus: fraudStatus ?? this.fraudStatus,
      fraudStats: fraudStats ?? this.fraudStats,
      fraudError: fraudError,
    );
  }

  @override
  List<Object?> get props => [
        walletStatus,
        walletStats,
        walletError,
        marketplaceStatus,
        marketplaceStats,
        marketplaceError,
        driversStatus,
        driversStats,
        driversError,
        fraudStatus,
        fraudStats,
        fraudError,
      ];
}


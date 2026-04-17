part of 'transport_admin_bloc.dart';

sealed class TransportAdminEvent extends Equatable {
  const TransportAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadWalletAdminStats extends TransportAdminEvent {
  const LoadWalletAdminStats();
}

class LoadMarketplaceAdminStats extends TransportAdminEvent {
  const LoadMarketplaceAdminStats();
}

class LoadDriversAdminStats extends TransportAdminEvent {
  const LoadDriversAdminStats();
}

class LoadFraudAdminStats extends TransportAdminEvent {
  const LoadFraudAdminStats();
}


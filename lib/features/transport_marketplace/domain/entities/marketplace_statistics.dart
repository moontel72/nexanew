import 'package:equatable/equatable.dart';

class MarketplaceStatistics extends Equatable {
  final int totalLoads;
  final int activeLoads;
  final int totalBids;
  final int activeShipments;

  const MarketplaceStatistics({
    required this.totalLoads,
    required this.activeLoads,
    required this.totalBids,
    required this.activeShipments,
  });

  @override
  List<Object> get props => [totalLoads, activeLoads, totalBids, activeShipments];
}


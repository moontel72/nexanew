// Customer Transit Models — Route, operator, seat matrix parsers.
// Maps GET /api/v1/consumer/transit/search responses (Module 8V).
// Migrated from features/consumer/data/models — see Backend-Dart Audit Plan §4.1(2).

/// A scheduled transit route between two cities.
class TransitRoute {
  final String id;
  final String operatorName;
  final String origin;
  final String destination;
  final String departureTime; // "HH:mm"
  final double pricePkr;
  final int totalSeats;
  final int availableSeats;

  const TransitRoute({
    required this.id,
    required this.operatorName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.pricePkr,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory TransitRoute.fromJson(Map<String, dynamic> json) => TransitRoute(
    id: json['id']?.toString() ?? '',
    operatorName: json['operator']?.toString() ?? '',
    origin: json['origin']?.toString() ?? '',
    destination: json['destination']?.toString() ?? '',
    departureTime: json['departure']?.toString() ?? '--:--',
    pricePkr: (json['price'] as num?)?.toDouble() ?? 0,
    totalSeats: (json['seats'] as num?)?.toInt() ?? 0,
    availableSeats: (json['available_seats'] as num?)?.toInt() ?? 0,
  );
}

/// Seat bitmask decoder: converts backend JSON seat array to local List<int>.
class SeatGrid {
  static List<int> decode(List<dynamic> rawSeats) =>
      rawSeats.map((s) => (s as num).toInt()).toList();

  static List<Map<String, dynamic>> encode(List<int> matrix, String routeId) =>
      [
        {'route_id': routeId, 'seats': matrix},
      ];
}

/// Fleet auction load summary (Module 12M).
class FleetAuctionLoad {
  final String loadId;
  final String origin;
  final String destination;
  final double currentBid;
  final DateTime biddingDeadline;

  const FleetAuctionLoad({
    required this.loadId,
    required this.origin,
    required this.destination,
    required this.currentBid,
    required this.biddingDeadline,
  });

  factory FleetAuctionLoad.fromJson(Map<String, dynamic> json) =>
      FleetAuctionLoad(
        loadId: json['load_id']?.toString() ?? '',
        origin: json['origin']?.toString() ?? '',
        destination: json['destination']?.toString() ?? '',
        currentBid: (json['current_bid'] as num?)?.toDouble() ?? 0,
        biddingDeadline:
            DateTime.tryParse(json['bidding_deadline']?.toString() ?? '') ??
            DateTime.now(),
      );
}

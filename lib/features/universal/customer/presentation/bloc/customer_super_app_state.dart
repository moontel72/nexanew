import 'package:equatable/equatable.dart';

class CustomerSuperAppState extends Equatable {
  // ── Authenticity ────────────────────────────────────────
  final int rewardPoints;
  final bool isScanning;
  final bool lastScanAuthentic; // true = authentic, false = counterfeit
  final String? lastScannedSerial;
  final int totalScans;

  // ── Transit ─────────────────────────────────────────────
  final List<Map<String, dynamic>> transitRoutes;
  final String? selectedRouteId;
  final Map<String, dynamic>? liveBusFrame; // Latest WebSocket frame

  // ── Seat Grid ───────────────────────────────────────────
  final List<int> seatMatrix; // 0=available, 1=booked, 2=selected
  final int selectedSeatCount;
  final double seatPrice;

  // ── Fleet Auction ───────────────────────────────────────
  final bool isBidding;
  final double? lastBidAmount;

  const CustomerSuperAppState({
    this.rewardPoints = 0,
    this.isScanning = false,
    this.lastScanAuthentic = true,
    this.lastScannedSerial,
    this.totalScans = 0,
    this.transitRoutes = const [],
    this.selectedRouteId,
    this.liveBusFrame,
    this.seatMatrix = const [],
    this.selectedSeatCount = 0,
    this.seatPrice = 0,
    this.isBidding = false,
    this.lastBidAmount,
  });

  CustomerSuperAppState copyWith({
    int? rewardPoints,
    bool? isScanning,
    bool? lastScanAuthentic,
    String? lastScannedSerial,
    int? totalScans,
    List<Map<String, dynamic>>? transitRoutes,
    String? selectedRouteId,
    Map<String, dynamic>? liveBusFrame,
    List<int>? seatMatrix,
    int? selectedSeatCount,
    double? seatPrice,
    bool? isBidding,
    double? lastBidAmount,
  }) => CustomerSuperAppState(
    rewardPoints: rewardPoints ?? this.rewardPoints,
    isScanning: isScanning ?? this.isScanning,
    lastScanAuthentic: lastScanAuthentic ?? this.lastScanAuthentic,
    lastScannedSerial: lastScannedSerial ?? this.lastScannedSerial,
    totalScans: totalScans ?? this.totalScans,
    transitRoutes: transitRoutes ?? this.transitRoutes,
    selectedRouteId: selectedRouteId ?? this.selectedRouteId,
    liveBusFrame: liveBusFrame ?? this.liveBusFrame,
    seatMatrix: seatMatrix ?? this.seatMatrix,
    selectedSeatCount: selectedSeatCount ?? this.selectedSeatCount,
    seatPrice: seatPrice ?? this.seatPrice,
    isBidding: isBidding ?? this.isBidding,
    lastBidAmount: lastBidAmount ?? this.lastBidAmount,
  );

  @override
  List<Object?> get props => [
    rewardPoints,
    isScanning,
    lastScanAuthentic,
    lastScannedSerial,
    totalScans,
    transitRoutes,
    selectedRouteId,
    liveBusFrame,
    seatMatrix,
    selectedSeatCount,
    seatPrice,
    isBidding,
    lastBidAmount,
  ];
}

import 'package:equatable/equatable.dart';

class FactoryDashboardState extends Equatable {
  // ── Production ───────────────────────────────────────────
  final int activeBatches;
  final int pendingBatches;
  final int dispatchedBatches;
  final int mismatchedBatches;
  final double throughputRate; // units per hour

  // ── Logistics ────────────────────────────────────────────
  final int activeTrucks;
  final int arrivingWithin30Min;
  final List<Map<String, dynamic>> shippingLanes;

  // ── Alerts ──────────────────────────────────────────────
  final bool hasCounterfeitAlert;
  final Map<String, dynamic>? counterfeitPayload;
  final bool hasGeoDiversionAlert;
  final Map<String, dynamic>? geoDiversionPayload;
  final bool hasScanArrival;
  final String? lastScanSerial;

  // ── Fleet ───────────────────────────────────────────────
  final Map<String, dynamic>? latestFleetFrame;

  const FactoryDashboardState({
    this.activeBatches = 0,
    this.pendingBatches = 0,
    this.dispatchedBatches = 0,
    this.mismatchedBatches = 0,
    this.throughputRate = 0,
    this.activeTrucks = 0,
    this.arrivingWithin30Min = 0,
    this.shippingLanes = const [],
    this.hasCounterfeitAlert = false,
    this.counterfeitPayload,
    this.hasGeoDiversionAlert = false,
    this.geoDiversionPayload,
    this.hasScanArrival = false,
    this.lastScanSerial,
    this.latestFleetFrame,
  });

  FactoryDashboardState copyWith({
    int? activeBatches, int? pendingBatches, int? dispatchedBatches,
    int? mismatchedBatches, double? throughputRate,
    int? activeTrucks, int? arrivingWithin30Min,
    List<Map<String, dynamic>>? shippingLanes,
    bool? hasCounterfeitAlert, Map<String, dynamic>? counterfeitPayload,
    bool? hasGeoDiversionAlert, Map<String, dynamic>? geoDiversionPayload,
    bool? hasScanArrival, String? lastScanSerial,
    Map<String, dynamic>? latestFleetFrame,
    bool clearAlerts = false,
  }) => FactoryDashboardState(
    activeBatches: activeBatches ?? this.activeBatches,
    pendingBatches: pendingBatches ?? this.pendingBatches,
    dispatchedBatches: dispatchedBatches ?? this.dispatchedBatches,
    mismatchedBatches: mismatchedBatches ?? this.mismatchedBatches,
    throughputRate: throughputRate ?? this.throughputRate,
    activeTrucks: activeTrucks ?? this.activeTrucks,
    arrivingWithin30Min: arrivingWithin30Min ?? this.arrivingWithin30Min,
    shippingLanes: shippingLanes ?? this.shippingLanes,
    hasCounterfeitAlert: clearAlerts ? false : hasCounterfeitAlert ?? this.hasCounterfeitAlert,
    counterfeitPayload: clearAlerts ? null : counterfeitPayload ?? this.counterfeitPayload,
    hasGeoDiversionAlert: clearAlerts ? false : hasGeoDiversionAlert ?? this.hasGeoDiversionAlert,
    geoDiversionPayload: clearAlerts ? null : geoDiversionPayload ?? this.geoDiversionPayload,
    hasScanArrival: hasScanArrival ?? this.hasScanArrival,
    lastScanSerial: lastScanSerial ?? this.lastScanSerial,
    latestFleetFrame: latestFleetFrame ?? this.latestFleetFrame,
  );

  @override
  List<Object?> get props => [
    activeBatches, pendingBatches, dispatchedBatches, mismatchedBatches,
    throughputRate, activeTrucks, arrivingWithin30Min, shippingLanes,
    hasCounterfeitAlert, counterfeitPayload, hasGeoDiversionAlert,
    geoDiversionPayload, hasScanArrival, lastScanSerial, latestFleetFrame,
  ];
}

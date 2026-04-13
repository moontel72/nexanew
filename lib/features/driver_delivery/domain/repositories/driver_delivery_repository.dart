import 'dart:async';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/delivery.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_earnings.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/driver_statistics.dart';
import 'package:nexatrace_system/features/driver_delivery/domain/entities/vehicle.dart';

/// Repository interface for Driver Delivery feature
abstract class DriverDeliveryRepository {
  /// Get driver's profile information
  Future<Driver> getDriverProfile();

  /// Update driver's profile information
  Future<Driver> updateDriverProfile({
    String? name,
    String? phone,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleNumber,
  });

  /// Get today's deliveries for the driver
  Future<List<Delivery>> getTodayDeliveries();

  /// Get delivery by ID
  Future<Delivery> getDeliveryById(String deliveryId);

  /// Get related deliveries (same area, same customer, etc.)
  Future<List<Delivery>> getRelatedDeliveries(String deliveryId);

  /// Get current active delivery
  Future<Delivery?> getCurrentDelivery();

  /// Start a delivery
  Future<Delivery> startDelivery(String deliveryId);

  /// Complete a delivery with proof
  Future<DeliveryCompletionResult> completeDelivery({
    required String deliveryId,
    String? proofImagePath,
    String? signaturePath,
    String? otp,
    String? notes,
  });

  /// Update delivery location
  Future<void> updateDeliveryLocation({
    required String deliveryId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
  });

  /// Mark driver attendance
  Future<AttendanceResult> markAttendance({
    required double latitude,
    required double longitude,
    String? notes,
  });

  /// Get driver earnings
  Future<DriverEarnings> getDriverEarnings({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get earnings history
  Future<List<DriverEarnings>> getEarningsHistory({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get delivery statistics
  Future<DriverStatistics> getDeliveryStatistics();

  /// Search deliveries
  Future<List<Delivery>> searchDeliveries({
    required String query,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  /// Filter deliveries
  Future<List<Delivery>> filterDeliveries({
    String? status,
    DateTime? date,
    String? area,
  });

  /// Update delivery status
  Future<Delivery> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? reason,
  });

  /// Get delivery route
  Future<DeliveryRoute> getDeliveryRoute(String deliveryId);

  /// Report delivery issue
  Future<void> reportDeliveryIssue({
    required String deliveryId,
    required String issueType,
    required String description,
    List<String>? imagePaths,
  });

  /// Get vehicle information
  Future<Vehicle?> getVehicleInfo();

  /// Update vehicle information
  Future<Vehicle> updateVehicleInfo({
    String? vehicleNumber,
    String? vehicleType,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? fitnessCertificateNumber,
    DateTime? fitnessExpiry,
  });

  /// Get driver rating
  Future<double> getDriverRating();

  /// Submit feedback for a delivery
  Future<void> submitFeedback({
    required String deliveryId,
    required int rating,
    String? comments,
  });

  /// Subscribe to delivery updates
  Stream<Delivery> subscribeToDeliveryUpdates(String deliveryId);

  /// Subscribe to driver status updates
  Stream<Driver> subscribeToDriverStatusUpdates();

  /// Get pending deliveries count
  Future<int> getPendingDeliveriesCount();

  /// Get completed deliveries count for today
  Future<int> getTodayCompletedDeliveriesCount();

  /// Get driver's current location
  Future<DriverLocation> getCurrentLocation();

  /// Update driver's availability status
  Future<void> updateAvailability(bool isAvailable);
}

/// Result of delivery completion
class DeliveryCompletionResult {
  final Delivery delivery;
  final String? proofUrl;
  final String? signatureUrl;

  DeliveryCompletionResult({
    required this.delivery,
    this.proofUrl,
    this.signatureUrl,
  });
}

/// Result of attendance marking
class AttendanceResult {
  final DateTime timestamp;
  final String location;

  AttendanceResult({
    required this.timestamp,
    required this.location,
  });
}

/// Delivery route information
class DeliveryRoute {
  final List<RoutePoint> points;
  final double totalDistance;
  final Duration estimatedDuration;
  final String polyline;

  DeliveryRoute({
    required this.points,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.polyline,
  });
}

/// Route point for delivery
class RoutePoint {
  final double latitude;
  final double longitude;
  final String? address;
  final String? instructions;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    this.address,
    this.instructions,
  });
}

/// Driver location information
class DriverLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final DateTime timestamp;

  DriverLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    required this.timestamp,
  });
}

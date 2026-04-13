//lib/features/driver_delivery/presentation/bloc/driver_delivery_event.dart
part of 'driver_delivery_bloc.dart';

/// Events for Driver Delivery BLoC
abstract class DriverDeliveryEvent extends Equatable {
  const DriverDeliveryEvent();

  @override
  List<Object?> get props => [];
}

/// Load driver's profile information
class LoadDriverProfile extends DriverDeliveryEvent {
  const LoadDriverProfile();
}

/// Update driver's profile information
class UpdateDriverProfile extends DriverDeliveryEvent {
  final String? name;
  final String? phone;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleNumber;

  const UpdateDriverProfile({
    this.name,
    this.phone,
    this.licenseNumber,
    this.vehicleType,
    this.vehicleNumber,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        licenseNumber,
        vehicleType,
        vehicleNumber,
      ];
}

/// Load today's deliveries for the driver
class LoadTodayDeliveries extends DriverDeliveryEvent {
  const LoadTodayDeliveries();
}

/// Load delivery by ID
class LoadDeliveryById extends DriverDeliveryEvent {
  final String deliveryId;

  const LoadDeliveryById(this.deliveryId);

  @override
  List<Object?> get props => [deliveryId];
}

/// Start a delivery
class StartDelivery extends DriverDeliveryEvent {
  final String deliveryId;

  const StartDelivery(this.deliveryId);

  @override
  List<Object?> get props => [deliveryId];
}

/// Complete a delivery with proof
class CompleteDelivery extends DriverDeliveryEvent {
  final String deliveryId;
  final String? proofImagePath;
  final String? signaturePath;
  final String? otp;
  final String? notes;

  const CompleteDelivery({
    required this.deliveryId,
    this.proofImagePath,
    this.signaturePath,
    this.otp,
    this.notes,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        proofImagePath,
        signaturePath,
        otp,
        notes,
      ];
}

/// Update delivery location
class UpdateDeliveryLocation extends DriverDeliveryEvent {
  final String deliveryId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;

  const UpdateDeliveryLocation({
    required this.deliveryId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        latitude,
        longitude,
        accuracy,
        speed,
      ];
}

/// Mark driver attendance
class MarkAttendance extends DriverDeliveryEvent {
  final double latitude;
  final double longitude;
  final String? notes;

  const MarkAttendance({
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  @override
  List<Object?> get props => [latitude, longitude, notes];
}

/// Load driver earnings
class LoadDriverEarnings extends DriverDeliveryEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDriverEarnings({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load delivery statistics
class LoadDeliveryStatistics extends DriverDeliveryEvent {
  const LoadDeliveryStatistics();
}

/// Search deliveries
class SearchDeliveries extends DriverDeliveryEvent {
  final String query;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  const SearchDeliveries({
    required this.query,
    this.startDate,
    this.endDate,
    this.status,
  });

  @override
  List<Object?> get props => [query, startDate, endDate, status];
}

/// Filter deliveries
class FilterDeliveries extends DriverDeliveryEvent {
  final String? status;
  final DateTime? date;
  final String? area;

  const FilterDeliveries({
    this.status,
    this.date,
    this.area,
  });

  @override
  List<Object?> get props => [status, date, area];
}

/// Refresh deliveries
class RefreshDeliveries extends DriverDeliveryEvent {
  const RefreshDeliveries();
}

/// Clear errors
class ClearErrors extends DriverDeliveryEvent {
  const ClearErrors();
}

/// Update delivery status
class UpdateDeliveryStatus extends DriverDeliveryEvent {
  final String deliveryId;
  final DeliveryStatus status;
  final String? reason;

  const UpdateDeliveryStatus({
    required this.deliveryId,
    required this.status,
    this.reason,
  });

  @override
  List<Object?> get props => [deliveryId, status, reason];
}

/// Load delivery route
class LoadDeliveryRoute extends DriverDeliveryEvent {
  final String deliveryId;

  const LoadDeliveryRoute(this.deliveryId);

  @override
  List<Object?> get props => [deliveryId];
}

/// Report delivery issue
class ReportDeliveryIssue extends DriverDeliveryEvent {
  final String deliveryId;
  final String issueType;
  final String description;
  final List<String>? imagePaths;

  const ReportDeliveryIssue({
    required this.deliveryId,
    required this.issueType,
    required this.description,
    this.imagePaths,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        issueType,
        description,
        imagePaths,
      ];
}

/// Load vehicle information
class LoadVehicleInfo extends DriverDeliveryEvent {
  const LoadVehicleInfo();
}

/// Update vehicle information
class UpdateVehicleInfo extends DriverDeliveryEvent {
  final String? vehicleNumber;
  final String? vehicleType;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? fitnessCertificateNumber;
  final DateTime? fitnessExpiry;

  const UpdateVehicleInfo({
    this.vehicleNumber,
    this.vehicleType,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.fitnessCertificateNumber,
    this.fitnessExpiry,
  });

  @override
  List<Object?> get props => [
        vehicleNumber,
        vehicleType,
        insuranceNumber,
        insuranceExpiry,
        fitnessCertificateNumber,
        fitnessExpiry,
      ];
}

/// Load driver rating
class LoadDriverRating extends DriverDeliveryEvent {
  const LoadDriverRating();
}

/// Submit feedback
class SubmitFeedback extends DriverDeliveryEvent {
  final String deliveryId;
  final int rating;
  final String? comments;

  const SubmitFeedback({
    required this.deliveryId,
    required this.rating,
    this.comments,
  });

  @override
  List<Object?> get props => [deliveryId, rating, comments];
}

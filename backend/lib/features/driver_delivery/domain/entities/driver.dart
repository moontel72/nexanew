import 'package:equatable/equatable.dart';

/// Driver status enumeration
enum DriverStatus {
  pending,
  active,
  suspended,
  inactive,
  onLeave,
  terminated,
}

/// Driver entity representing a delivery driver
class Driver extends Equatable {
  final String id;
  final String userId;
  final String companyId;
  final String? name;
  final String? email;
  final String? phone;
  final String? licenseNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final DriverStatus status;
  final double? rating;
  final int totalDeliveries;
  final int successfulDeliveries;
  final int failedDeliveries;
  final double totalEarnings;
  final double currentBalance;
  final DateTime? lastActiveAt;
  final DateTime? hiredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.userId,
    required this.companyId,
    this.name,
    this.email,
    this.phone,
    this.licenseNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.status = DriverStatus.pending,
    this.rating,
    this.totalDeliveries = 0,
    this.successfulDeliveries = 0,
    this.failedDeliveries = 0,
    this.totalEarnings = 0.0,
    this.currentBalance = 0.0,
    this.lastActiveAt,
    this.hiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this driver with updated values
  Driver copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleNumber,
    DriverStatus? status,
    double? rating,
    int? totalDeliveries,
    int? successfulDeliveries,
    int? failedDeliveries,
    double? totalEarnings,
    double? currentBalance,
    DateTime? lastActiveAt,
    DateTime? hiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      successfulDeliveries: successfulDeliveries ?? this.successfulDeliveries,
      failedDeliveries: failedDeliveries ?? this.failedDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currentBalance: currentBalance ?? this.currentBalance,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      hiredAt: hiredAt ?? this.hiredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if driver is currently active
  bool get isActive => status == DriverStatus.active;

  /// Check if driver is available for new deliveries
  bool get isAvailable =>
      isActive &&
      (lastActiveAt == null ||
          DateTime.now().difference(lastActiveAt!).inHours < 24);

  /// Get driver's success rate
  double get successRate {
    if (totalDeliveries == 0) return 0.0;
    return (successfulDeliveries / totalDeliveries) * 100;
  }

  /// Get driver's average rating
  double get averageRating => rating ?? 0.0;

  /// Check if driver has valid license
  bool get hasValidLicense =>
      licenseNumber != null && licenseNumber!.isNotEmpty;

  /// Check if driver has assigned vehicle
  bool get hasVehicle => vehicleNumber != null && vehicleNumber!.isNotEmpty;

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'name': name,
      'email': email,
      'phone': phone,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'status': status.name,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'successful_deliveries': successfulDeliveries,
      'failed_deliveries': failedDeliveries,
      'total_earnings': totalEarnings,
      'current_balance': currentBalance,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'hired_at': hiredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      status: DriverStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => DriverStatus.pending,
      ),
      rating: json['rating'] as double?,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      successfulDeliveries: json['successful_deliveries'] as int? ?? 0,
      failedDeliveries: json['failed_deliveries'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      hiredAt: json['hired_at'] != null
          ? DateTime.parse(json['hired_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        name,
        email,
        phone,
        licenseNumber,
        vehicleType,
        vehicleNumber,
        status,
        rating,
        totalDeliveries,
        successfulDeliveries,
        failedDeliveries,
        totalEarnings,
        currentBalance,
        lastActiveAt,
        hiredAt,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}

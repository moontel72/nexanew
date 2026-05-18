import 'package:equatable/equatable.dart';
import 'package:nexatrace_system/features/factory/driver/domain/entities/trip.dart';

/// Driver entity for factory driver profile
class FactoryDriver extends Equatable {
  final String id;
  final String userId;
  final String factoryId;
  final String name;
  final String? email;
  final String phone;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? vehiclePlateNumber;
  final String? vehicleType;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final DateTime? registrationExpiry;
  final double rating;
  final int totalTrips;
  final int completedTrips;
  final int onTimeDeliveries;
  final int lateDeliveries;
  final double totalEarnings;
  final double currentBalance;
  final int dailyScanCount;
  final double photoQualityScore;
  final DriverTier tier;
  final bool isBlocked;
  final String? blockReason;
  final double drivingHoursToday;
  final double drivingHoursWeek;
  final bool isFatigued;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FactoryDriver({
    required this.id,
    required this.userId,
    required this.factoryId,
    required this.name,
    this.email,
    required this.phone,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehiclePlateNumber,
    this.vehicleType,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.registrationExpiry,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.completedTrips = 0,
    this.onTimeDeliveries = 0,
    this.lateDeliveries = 0,
    this.totalEarnings = 0.0,
    this.currentBalance = 0.0,
    this.dailyScanCount = 0,
    this.photoQualityScore = 0.0,
    this.tier = DriverTier.bronze,
    this.isBlocked = false,
    this.blockReason,
    this.drivingHoursToday = 0.0,
    this.drivingHoursWeek = 0.0,
    this.isFatigued = false,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  FactoryDriver copyWith({
    String? id,
    String? userId,
    String? factoryId,
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? vehiclePlateNumber,
    String? vehicleType,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    DateTime? registrationExpiry,
    double? rating,
    int? totalTrips,
    int? completedTrips,
    int? onTimeDeliveries,
    int? lateDeliveries,
    double? totalEarnings,
    double? currentBalance,
    int? dailyScanCount,
    double? photoQualityScore,
    DriverTier? tier,
    bool? isBlocked,
    String? blockReason,
    double? drivingHoursToday,
    double? drivingHoursWeek,
    bool? isFatigued,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FactoryDriver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      factoryId: factoryId ?? this.factoryId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      completedTrips: completedTrips ?? this.completedTrips,
      onTimeDeliveries: onTimeDeliveries ?? this.onTimeDeliveries,
      lateDeliveries: lateDeliveries ?? this.lateDeliveries,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currentBalance: currentBalance ?? this.currentBalance,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      photoQualityScore: photoQualityScore ?? this.photoQualityScore,
      tier: tier ?? this.tier,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      drivingHoursToday: drivingHoursToday ?? this.drivingHoursToday,
      drivingHoursWeek: drivingHoursWeek ?? this.drivingHoursWeek,
      isFatigued: isFatigued ?? this.isFatigued,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// KPI: on-time delivery percentage (4AA)
  double get onTimePercentage {
    final total = onTimeDeliveries + lateDeliveries;
    if (total == 0) return 100.0;
    return (onTimeDeliveries / total) * 100.0;
  }

  /// Whether license is expired (4Y)
  bool get isLicenseExpired {
    if (licenseExpiry == null) return false;
    return DateTime.now().isAfter(licenseExpiry!);
  }

  /// Whether license expires within 30 days (4Y)
  bool get isLicenseExpiringSoon {
    if (licenseExpiry == null) return false;
    return licenseExpiry!.difference(DateTime.now()).inDays <= 30 &&
        !isLicenseExpired;
  }

  /// Whether insurance is expired (4Y)
  bool get isInsuranceExpired {
    if (insuranceExpiry == null) return false;
    return DateTime.now().isAfter(insuranceExpiry!);
  }

  /// Whether any document needs renewal (4Y)
  bool get hasDocExpiryWarning =>
      isLicenseExpiringSoon ||
      isInsuranceExpired ||
      (registrationExpiry != null &&
          registrationExpiry!.difference(DateTime.now()).inDays <= 30);

  /// Whether driver can accept trips (4Y, 4AC)
  bool get canAcceptTrips => !isBlocked && !isFatigued && !isLicenseExpired;

  /// Whether fatigue threshold exceeded (4AC)
  bool get isFatigueThresholdExceeded => drivingHoursToday >= 12.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'factory_id': factoryId,
      'name': name,
      'email': email,
      'phone': phone,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'vehicle_plate_number': vehiclePlateNumber,
      'vehicle_type': vehicleType,
      'insurance_number': insuranceNumber,
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'registration_expiry': registrationExpiry?.toIso8601String(),
      'rating': rating,
      'total_trips': totalTrips,
      'completed_trips': completedTrips,
      'on_time_deliveries': onTimeDeliveries,
      'late_deliveries': lateDeliveries,
      'total_earnings': totalEarnings,
      'current_balance': currentBalance,
      'daily_scan_count': dailyScanCount,
      'photo_quality_score': photoQualityScore,
      'tier': tier.name,
      'is_blocked': isBlocked,
      'block_reason': blockReason,
      'driving_hours_today': drivingHoursToday,
      'driving_hours_week': drivingHoursWeek,
      'is_fatigued': isFatigued,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FactoryDriver.fromJson(Map<String, dynamic> json) {
    return FactoryDriver(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      factoryId: json['factory_id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String? ?? '',
      licenseNumber: json['license_number'] as String?,
      licenseExpiry: json['license_expiry'] != null
          ? DateTime.parse(json['license_expiry'] as String)
          : null,
      vehiclePlateNumber: json['vehicle_plate_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      insuranceNumber: json['insurance_number'] as String?,
      insuranceExpiry: json['insurance_expiry'] != null
          ? DateTime.parse(json['insurance_expiry'] as String)
          : null,
      registrationExpiry: json['registration_expiry'] != null
          ? DateTime.parse(json['registration_expiry'] as String)
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] as int? ?? 0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      onTimeDeliveries: json['on_time_deliveries'] as int? ?? 0,
      lateDeliveries: json['late_deliveries'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      dailyScanCount: json['daily_scan_count'] as int? ?? 0,
      photoQualityScore:
          (json['photo_quality_score'] as num?)?.toDouble() ?? 0.0,
      tier: DriverTier.values.firstWhere(
        (e) => e.name == (json['tier'] as String? ?? 'bronze'),
        orElse: () => DriverTier.bronze,
      ),
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
      drivingHoursToday:
          (json['driving_hours_today'] as num?)?.toDouble() ?? 0.0,
      drivingHoursWeek: (json['driving_hours_week'] as num?)?.toDouble() ?? 0.0,
      isFatigued: json['is_fatigued'] as bool? ?? false,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    factoryId,
    name,
    email,
    phone,
    licenseNumber,
    licenseExpiry,
    vehiclePlateNumber,
    vehicleType,
    insuranceNumber,
    insuranceExpiry,
    registrationExpiry,
    rating,
    totalTrips,
    completedTrips,
    onTimeDeliveries,
    lateDeliveries,
    totalEarnings,
    currentBalance,
    dailyScanCount,
    photoQualityScore,
    tier,
    isBlocked,
    blockReason,
    drivingHoursToday,
    drivingHoursWeek,
    isFatigued,
    lastActiveAt,
    createdAt,
    updatedAt,
  ];
}

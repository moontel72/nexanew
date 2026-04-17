import 'package:equatable/equatable.dart';

/// Vehicle type enumeration
enum VehicleType {
  motorcycle,
  scooter,
  bicycle,
  car,
  van,
  truck,
  threeWheeler,
  other,
}

/// Vehicle entity representing a driver's vehicle
class Vehicle extends Equatable {
  final String id;
  final String driverId;
  final String companyId;
  final String vehicleNumber;
  final VehicleType vehicleType;
  final String? make;
  final String? model;
  final int? year;
  final String? color;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final String? fitnessCertificateNumber;
  final DateTime? fitnessExpiry;
  final String? registrationCertificateNumber;
  final DateTime? registrationExpiry;
  final String? pollutionCertificateNumber;
  final DateTime? pollutionExpiry;
  final double? maxLoadCapacity;
  final String? loadCapacityUnit;
  final double? fuelEfficiency;
  final String? fuelType;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.driverId,
    required this.companyId,
    required this.vehicleNumber,
    required this.vehicleType,
    this.make,
    this.model,
    this.year,
    this.color,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.fitnessCertificateNumber,
    this.fitnessExpiry,
    this.registrationCertificateNumber,
    this.registrationExpiry,
    this.pollutionCertificateNumber,
    this.pollutionExpiry,
    this.maxLoadCapacity,
    this.loadCapacityUnit,
    this.fuelEfficiency,
    this.fuelType,
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        driverId,
        companyId,
        vehicleNumber,
        vehicleType,
        make,
        model,
        year,
        color,
        insuranceNumber,
        insuranceExpiry,
        fitnessCertificateNumber,
        fitnessExpiry,
        registrationCertificateNumber,
        registrationExpiry,
        pollutionCertificateNumber,
        pollutionExpiry,
        maxLoadCapacity,
        loadCapacityUnit,
        fuelEfficiency,
        fuelType,
        isActive,
        notes,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this Vehicle with the given fields replaced
  Vehicle copyWith({
    String? id,
    String? driverId,
    String? companyId,
    String? vehicleNumber,
    VehicleType? vehicleType,
    String? make,
    String? model,
    int? year,
    String? color,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    String? fitnessCertificateNumber,
    DateTime? fitnessExpiry,
    String? registrationCertificateNumber,
    DateTime? registrationExpiry,
    String? pollutionCertificateNumber,
    DateTime? pollutionExpiry,
    double? maxLoadCapacity,
    String? loadCapacityUnit,
    double? fuelEfficiency,
    String? fuelType,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      companyId: companyId ?? this.companyId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      fitnessCertificateNumber:
          fitnessCertificateNumber ?? this.fitnessCertificateNumber,
      fitnessExpiry: fitnessExpiry ?? this.fitnessExpiry,
      registrationCertificateNumber:
          registrationCertificateNumber ?? this.registrationCertificateNumber,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      pollutionCertificateNumber:
          pollutionCertificateNumber ?? this.pollutionCertificateNumber,
      pollutionExpiry: pollutionExpiry ?? this.pollutionExpiry,
      maxLoadCapacity: maxLoadCapacity ?? this.maxLoadCapacity,
      loadCapacityUnit: loadCapacityUnit ?? this.loadCapacityUnit,
      fuelEfficiency: fuelEfficiency ?? this.fuelEfficiency,
      fuelType: fuelType ?? this.fuelType,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a Vehicle from JSON data
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      companyId: json['company_id'] as String,
      vehicleNumber: json['vehicle_number'] as String,
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == (json['vehicle_type'] as String? ?? 'other'),
        orElse: () => VehicleType.other,
      ),
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      insuranceNumber: json['insurance_number'] as String?,
      insuranceExpiry: json['insurance_expiry'] != null
          ? DateTime.parse(json['insurance_expiry'] as String)
          : null,
      fitnessCertificateNumber: json['fitness_certificate_number'] as String?,
      fitnessExpiry: json['fitness_expiry'] != null
          ? DateTime.parse(json['fitness_expiry'] as String)
          : null,
      registrationCertificateNumber:
          json['registration_certificate_number'] as String?,
      registrationExpiry: json['registration_expiry'] != null
          ? DateTime.parse(json['registration_expiry'] as String)
          : null,
      pollutionCertificateNumber:
          json['pollution_certificate_number'] as String?,
      pollutionExpiry: json['pollution_expiry'] != null
          ? DateTime.parse(json['pollution_expiry'] as String)
          : null,
      maxLoadCapacity: (json['max_load_capacity'] as num?)?.toDouble(),
      loadCapacityUnit: json['load_capacity_unit'] as String?,
      fuelEfficiency: (json['fuel_efficiency'] as num?)?.toDouble(),
      fuelType: json['fuel_type'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this Vehicle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'company_id': companyId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType.name,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'insurance_number': insuranceNumber,
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'fitness_certificate_number': fitnessCertificateNumber,
      'fitness_expiry': fitnessExpiry?.toIso8601String(),
      'registration_certificate_number': registrationCertificateNumber,
      'registration_expiry': registrationExpiry?.toIso8601String(),
      'pollution_certificate_number': pollutionCertificateNumber,
      'pollution_expiry': pollutionExpiry?.toIso8601String(),
      'max_load_capacity': maxLoadCapacity,
      'load_capacity_unit': loadCapacityUnit,
      'fuel_efficiency': fuelEfficiency,
      'fuel_type': fuelType,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Returns a string representation of this Vehicle
  @override
  String toString() {
    return 'Vehicle(id: $id, vehicleNumber: $vehicleNumber, vehicleType: $vehicleType)';
  }

  /// Checks if the vehicle has valid insurance
  bool get hasValidInsurance {
    if (insuranceExpiry == null) return false;
    return insuranceExpiry!.isAfter(DateTime.now());
  }

  /// Checks if the vehicle has valid fitness certificate
  bool get hasValidFitnessCertificate {
    if (fitnessExpiry == null) return false;
    return fitnessExpiry!.isAfter(DateTime.now());
  }

  /// Checks if the vehicle has valid registration
  bool get hasValidRegistration {
    if (registrationExpiry == null) return false;
    return registrationExpiry!.isAfter(DateTime.now());
  }

  /// Checks if the vehicle has valid pollution certificate
  bool get hasValidPollutionCertificate {
    if (pollutionExpiry == null) return false;
    return pollutionExpiry!.isAfter(DateTime.now());
  }

  /// Checks if the vehicle is fully compliant (all certificates valid)
  bool get isFullyCompliant {
    return hasValidInsurance &&
        hasValidFitnessCertificate &&
        hasValidRegistration &&
        hasValidPollutionCertificate;
  }

  /// Gets the next expiry date among all certificates
  DateTime? get nextExpiryDate {
    final dates = [
      insuranceExpiry,
      fitnessExpiry,
      registrationExpiry,
      pollutionExpiry,
    ].whereType<DateTime>().toList();

    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  /// Checks if any certificate is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final nextExpiry = nextExpiryDate;
    if (nextExpiry == null) return false;
    return nextExpiry.difference(DateTime.now()).inDays <= 30;
  }

  /// Gets the vehicle display name
  String get displayName {
    final parts = <String>[];
    if (make != null && make!.isNotEmpty) parts.add(make!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    if (year != null) parts.add(year.toString());
    if (parts.isEmpty) return vehicleNumber;
    return '${parts.join(' ')} ($vehicleNumber)';
  }
}

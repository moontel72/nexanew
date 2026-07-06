// Driver Profile — type-safe, Equatable model
import 'package:equatable/equatable.dart';

class DriverProfile extends Equatable {
  final String id, name, vehiclePlate, activeRoute, scheduleStatus, nextStop;
  final int totalSeats, bookedSeats;
  final String? licenseNumber, phone;

  const DriverProfile({
    required this.id,
    required this.name,
    this.vehiclePlate = '--',
    this.activeRoute = 'No active route',
    this.scheduleStatus = 'Off Duty',
    this.nextStop = '--',
    this.totalSeats = 0,
    this.bookedSeats = 0,
    this.licenseNumber,
    this.phone,
  });

  int get vacantSeats => totalSeats - bookedSeats;
  bool get isOnDuty =>
      ['active', 'on route', 'driving'].contains(scheduleStatus.toLowerCase());

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
    id: json['id']?.toString() ?? '',
    name:
        json['account_name']?.toString() ??
        json['display_name']?.toString() ??
        'Driver',
    vehiclePlate: json['vehicle_plate']?.toString() ?? '--',
    activeRoute: json['active_route']?.toString() ?? 'No active route',
    scheduleStatus: json['schedule_status']?.toString() ?? 'Off Duty',
    nextStop: json['next_stop']?.toString() ?? '--',
    totalSeats: (json['total_seats'] ?? 0) as int,
    bookedSeats: (json['booked_seats'] ?? 0) as int,
    licenseNumber: json['license_number']?.toString(),
    phone: json['phone']?.toString(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    vehiclePlate,
    activeRoute,
    scheduleStatus,
    nextStop,
    totalSeats,
    bookedSeats,
  ];
}

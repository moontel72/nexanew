// Conductor models — type-safe, Equatable
import 'package:equatable/equatable.dart';

class ConductorProfile extends Equatable {
  final String id, name, routeName;
  final int totalSeats;
  final double? starRating;
  final int? completedTrips;
  final String? phone, licenseNumber;
  final String? linkedCarrierName, linkedCarrierId;

  const ConductorProfile({
    required this.id,
    required this.name,
    this.routeName = '--',
    this.totalSeats = 52,
    this.starRating,
    this.completedTrips,
    this.phone,
    this.licenseNumber,
    this.linkedCarrierName,
    this.linkedCarrierId,
  });

  factory ConductorProfile.fromJson(Map<String, dynamic> json) =>
      ConductorProfile(
        id: json['id']?.toString() ?? '',
        name:
            json['account_name']?.toString() ??
            json['display_name']?.toString() ??
            'Conductor',
        routeName: json['active_route']?.toString() ?? '--',
        totalSeats: (json['total_seats'] ?? 52) as int,
        starRating: (json['star_rating'] ?? json['rating'])?.toDouble(),
        completedTrips: json['completed_trips'] as int?,
        phone: json['phone']?.toString(),
        licenseNumber: json['license_number']?.toString(),
        linkedCarrierName: json['carrier_name']?.toString(),
        linkedCarrierId: json['carrier_company_id']?.toString(),
      );

  @override
  List<Object?> get props => [
    id,
    name,
    routeName,
    totalSeats,
    starRating,
    completedTrips,
    linkedCarrierId,
  ];
}

class TicketManifest extends Equatable {
  final int totalSeats, bookedSeats, soldSeats;
  final double totalRevenue;
  final String activeRouteLeg;
  final List<Map<String, dynamic>> seats;
  final DateTime lastSync;

  const TicketManifest({
    this.totalSeats = 0,
    this.bookedSeats = 0,
    this.soldSeats = 0,
    this.totalRevenue = 0,
    this.activeRouteLeg = '--',
    this.seats = const [],
    required this.lastSync,
  });

  int get vacantSeats => totalSeats - bookedSeats;

  factory TicketManifest.fromJson(Map<String, dynamic> json) => TicketManifest(
    totalSeats: (json['total_seats'] ?? 0) as int,
    bookedSeats: (json['booked_seats'] ?? 0) as int,
    soldSeats: (json['sold_seats'] ?? json['booked_seats'] ?? 0) as int,
    totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    activeRouteLeg:
        json['active_route_leg']?.toString() ??
        json['active_route']?.toString() ??
        '--',
    seats: (json['seats'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
    lastSync: DateTime.now(),
  );

  /// Fallback when network fails — returns last known state.
  factory TicketManifest.cached(TicketManifest? last) => TicketManifest(
    totalSeats: last?.totalSeats ?? 0,
    bookedSeats: last?.bookedSeats ?? 0,
    soldSeats: last?.soldSeats ?? 0,
    totalRevenue: last?.totalRevenue ?? 0,
    activeRouteLeg: last?.activeRouteLeg ?? '--',
    seats: last?.seats ?? const [],
    lastSync: last?.lastSync ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [
    totalSeats,
    bookedSeats,
    soldSeats,
    totalRevenue,
    activeRouteLeg,
    lastSync,
  ];
}

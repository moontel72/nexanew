// NEXATRACE — TICKET VAULT SERVICE
// ===================================
// Hive-powered offline ticket cache for storing
// finalized booking QR tickets. Survives network
// drops and cellular dead zones.
//
// MODULE: 8V — Digital QR Ticketing Vault

import 'dart:convert';
import 'package:hive/hive.dart';

/// A single cached ticket entry stored in Hive.
class CachedBusTicket {
  final String bookingId;
  final String busId;
  final String layoutId;
  final String tripId;
  final int seatNumber;
  final String seatLabel;
  final String busDisplayName;
  final double ticketPrice;
  final String paymentMethod;
  final DateTime bookedAt;
  final String? qrPayload;
  final String status; // 'active', 'used', 'expired', 'cancelled'

  const CachedBusTicket({
    required this.bookingId,
    required this.busId,
    required this.layoutId,
    required this.tripId,
    required this.seatNumber,
    required this.seatLabel,
    required this.busDisplayName,
    required this.ticketPrice,
    required this.paymentMethod,
    required this.bookedAt,
    this.qrPayload,
    this.status = 'active',
  });

  /// Serialize to JSON for Hive storage.
  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'bus_id': busId,
    'layout_id': layoutId,
    'trip_id': tripId,
    'seat_number': seatNumber,
    'seat_label': seatLabel,
    'bus_display_name': busDisplayName,
    'ticket_price': ticketPrice,
    'payment_method': paymentMethod,
    'booked_at': bookedAt.toIso8601String(),
    'qr_payload': qrPayload ?? '',
    'status': status,
  };

  /// Deserialize from JSON.
  factory CachedBusTicket.fromJson(Map<String, dynamic> json) {
    return CachedBusTicket(
      bookingId: json['booking_id']?.toString() ?? '',
      busId: json['bus_id']?.toString() ?? '',
      layoutId: json['layout_id']?.toString() ?? '',
      tripId: json['trip_id']?.toString() ?? '',
      seatNumber: (json['seat_number'] ?? 0) as int,
      seatLabel: json['seat_label']?.toString() ?? '',
      busDisplayName: json['bus_display_name']?.toString() ?? '',
      ticketPrice: (json['ticket_price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method']?.toString() ?? '',
      bookedAt:
          DateTime.tryParse(json['booked_at']?.toString() ?? '') ??
          DateTime.now(),
      qrPayload: json['qr_payload']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }

  /// Human-readable date string for display.
  String get bookedAtDisplay {
    final d = bookedAt;
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  /// Whether this ticket is still valid.
  bool get isValid => status == 'active';

  /// Generate a simple display QR string from booking ID.
  String get displayQr => 'NEXA:$bookingId';
}

/// Hive-based service for offline ticket storage and retrieval.
class TicketVaultService {
  static const _boxName = 'bus_tickets';

  Box<Map>? _box;

  /// Initialize the Hive box. Call once at app startup.
  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Save a ticket to the offline vault.
  Future<void> saveTicket(CachedBusTicket ticket) async {
    if (_box == null) await init();
    await _box!.put(ticket.bookingId, ticket.toJson());
  }

  /// Get all cached tickets, newest first.
  List<CachedBusTicket> getAllTickets() {
    if (_box == null) return [];
    return _box!.values
        .map((m) => CachedBusTicket.fromJson(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  }

  /// Get active (unused) tickets only.
  List<CachedBusTicket> getActiveTickets() {
    return getAllTickets().where((t) => t.isValid).toList();
  }

  /// Get a specific ticket by booking ID.
  CachedBusTicket? getTicket(String bookingId) {
    if (_box == null) return null;
    final raw = _box!.get(bookingId);
    if (raw == null) return null;
    return CachedBusTicket.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Mark a ticket as used.
  Future<void> markUsed(String bookingId) async {
    final ticket = getTicket(bookingId);
    if (ticket != null) {
      await _box!.put(bookingId, ticket.copyWithStatus('used').toJson());
    }
  }

  /// Mark a ticket as cancelled.
  Future<void> markCancelled(String bookingId) async {
    final ticket = getTicket(bookingId);
    if (ticket != null) {
      await _box!.put(bookingId, ticket.copyWithStatus('cancelled').toJson());
    }
  }

  /// Delete a ticket from the vault.
  Future<void> deleteTicket(String bookingId) async {
    await _box?.delete(bookingId);
  }

  /// Number of cached tickets.
  int get ticketCount => _box?.length ?? 0;

  /// Check if vault is initialized.
  bool get isReady => _box != null && _box!.isOpen;

  /// Close the Hive box.
  Future<void> close() async {
    await _box?.close();
  }
}

// ── Extension for copyWith ──

extension CachedBusTicketX on CachedBusTicket {
  CachedBusTicket copyWithStatus(String newStatus) {
    return CachedBusTicket(
      bookingId: bookingId,
      busId: busId,
      layoutId: layoutId,
      tripId: tripId,
      seatNumber: seatNumber,
      seatLabel: seatLabel,
      busDisplayName: busDisplayName,
      ticketPrice: ticketPrice,
      paymentMethod: paymentMethod,
      bookedAt: bookedAt,
      qrPayload: qrPayload,
      status: newStatus,
    );
  }
}

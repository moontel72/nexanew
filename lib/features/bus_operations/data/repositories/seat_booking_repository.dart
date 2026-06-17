// NEXATRACE — SEAT BOOKING REPOSITORY
// ======================================
// Data layer for passenger seat booking operations.
// Communicates with the BusInventoryService backend via
// POST /api/v1/bus-fleet/bookings and GET layout endpoints.
//
// MODULE: 8V — Unified Bus Transit Terminal

import 'package:trace_odd/core/services/api_service.dart';

/// Structured result from the booking API.
class SeatBookingResult {
  final bool success;
  final String? bookingId;
  final int seatNumber;
  final double ticketPrice;
  final String? paymentReference;
  final String? errorMessage;

  const SeatBookingResult({
    required this.success,
    this.bookingId,
    required this.seatNumber,
    required this.ticketPrice,
    this.paymentReference,
    this.errorMessage,
  });

  factory SeatBookingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SeatBookingResult(
      success: json['success'] == true,
      bookingId: data['booking_id']?.toString(),
      seatNumber: (data['seat_number'] ?? 0) as int,
      ticketPrice: (data['payment']?['amount'] ?? data['ticket_price'] ?? 0)
          .toDouble(),
      paymentReference: data['payment']?['reference_id']?.toString(),
      errorMessage: json['message']?.toString(),
    );
  }

  factory SeatBookingResult.failure(String message, {int seatNumber = 0}) {
    return SeatBookingResult(
      success: false,
      seatNumber: seatNumber,
      ticketPrice: 0,
      errorMessage: message,
    );
  }
}

/// Result from fetching a bus layout with booking status.
class BusLayoutResult {
  final String layoutId;
  final String displayName;
  final Map<String, dynamic> snapshot;
  final List<int> bookedSeatNumbers;
  final int totalSeats;
  final int availableSeats;

  const BusLayoutResult({
    required this.layoutId,
    required this.displayName,
    required this.snapshot,
    required this.bookedSeatNumbers,
    required this.totalSeats,
    required this.availableSeats,
  });
}

/// Repository for passenger seat booking operations.
class SeatBookingRepository {
  final ApiService _api;

  SeatBookingRepository({ApiService? api}) : _api = api ?? ApiService();

  // ── FETCH LAYOUT ────────────────────────────────────

  /// Fetch a published bus layout with live booking status.
  /// Uses the public endpoint (no auth required) so guest customers
  /// can browse seat maps before sign-in. Only published layouts are returned.
  Future<BusLayoutResult> fetchLayout(String layoutId, {String? tripId}) async {
    final response = await _api.get(
      '/bus-fleet/absolute-layouts/$layoutId/public',
      queryParams: {'include_bookings': 'true'},
      requiresAuth: false,
    );

    final data = _safeMap(response['data'] ?? response);
    final snapshot = _safeMap(
      data['current_snapshot'] ?? data['snapshot'] ?? {},
    );
    final bookingsRaw =
        data['booked_seats'] ?? data['booked_seat_numbers'] ?? [];

    List<int> bookedSeats = [];
    if (bookingsRaw is List) {
      bookedSeats = bookingsRaw
          .map((b) => b is int ? b : int.tryParse(b.toString()) ?? 0)
          .where((n) => n > 0)
          .toList();
    }

    return BusLayoutResult(
      layoutId: layoutId,
      displayName:
          (data['display_name'] ??
                  data['bus_registration'] ??
                  'Bus ${layoutId.substring(0, layoutId.length < 8 ? layoutId.length : 8)}')
              .toString(),
      snapshot: snapshot,
      bookedSeatNumbers: bookedSeats,
      totalSeats: (data['total_seats'] ?? 0) as int,
      availableSeats: (data['available_seats'] ?? 0) as int,
    );
  }

  // ── BOOK SEAT ───────────────────────────────────────

  /// Book a seat with payment method.
  Future<SeatBookingResult> bookSeat({
    required String busId,
    required String tripId,
    required int seatNumber,
    required String paymentMethod,
    required double ticketPrice,
    String? voucherCode,
    String? busOwnerId,
  }) async {
    try {
      final body = <String, dynamic>{
        'bus_id': busId,
        'trip_id': tripId,
        'seat_number': seatNumber,
        'payment_method': paymentMethod,
        'ticket_price': ticketPrice,
      };

      if (voucherCode != null && voucherCode.isNotEmpty) {
        body['voucher_code'] = voucherCode;
      }
      if (busOwnerId != null && busOwnerId.isNotEmpty) {
        body['bus_owner_id'] = busOwnerId;
      }

      final response = await _api.post('/bus-fleet/bookings', body: body);
      final json = _safeMap(response);

      if (json['success'] == false) {
        return SeatBookingResult.failure(
          json['message']?.toString() ?? 'Booking failed',
          seatNumber: seatNumber,
        );
      }
      return SeatBookingResult.fromJson(json);
    } catch (e) {
      return SeatBookingResult.failure(
        _humanizeError(e),
        seatNumber: seatNumber,
      );
    }
  }

  // ── REFRESH BOOKINGS ────────────────────────────────

  Future<List<int>> fetchBookedSeats(String layoutId, {String? tripId}) async {
    try {
      final response = await _api.get(
        '/bus-fleet/absolute-layouts/$layoutId/public',
        queryParams: {'include_bookings': 'true'},
        requiresAuth: false,
      );
      final data = _safeMap(response['data'] ?? response);
      final raw = data['booked_seats'] ?? data['booked_seat_numbers'] ?? [];
      if (raw is List) {
        return raw
            .map((b) => b is int ? b : int.tryParse(b.toString()) ?? 0)
            .where((n) => n > 0)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── HELPERS ─────────────────────────────────────────

  Map<String, dynamic> _safeMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return {};
  }

  String _humanizeError(Object e) {
    final msg = e.toString();
    if (msg.contains('already booked')) {
      return 'This seat was just taken. Please choose another.';
    }
    if (msg.contains('does not exist')) return 'Seat not found.';
    if (msg.contains('insufficient')) {
      return 'Insufficient wallet balance.';
    }
    if (msg.contains('voucher')) return 'Voucher is invalid or already used.';
    if (msg.contains('timeout') || msg.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    return msg
        .replaceAll('Exception: ', '')
        .replaceAll('RuntimeException: ', '');
  }
}

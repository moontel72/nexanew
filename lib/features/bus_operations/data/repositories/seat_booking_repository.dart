// NEXATRACE — SEAT BOOKING REPOSITORY v2
// ======================================
// Data layer for passenger seat operations.
// Phase 2: Hold/Reserve → Confirm/Pay → Release cycle.
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

/// Result from holding a seat.
class SeatHoldResult {
  final bool success;
  final String? holdToken;
  final String? expiresAt;
  final int expiresInSeconds;
  final String? errorMessage;

  const SeatHoldResult({
    required this.success,
    this.holdToken,
    this.expiresAt,
    this.expiresInSeconds = 0,
    this.errorMessage,
  });

  factory SeatHoldResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SeatHoldResult(
      success: json['success'] == true,
      holdToken: data['hold_token']?.toString(),
      expiresAt: data['expires_at']?.toString(),
      expiresInSeconds: (data['expires_in_seconds'] ?? 0) as int,
      errorMessage: json['message']?.toString(),
    );
  }

  factory SeatHoldResult.failure(String message) =>
      SeatHoldResult(success: false, errorMessage: message);
}

/// Result from releasing a hold.
class SeatReleaseResult {
  final bool success;
  final int seatNumber;
  final String? errorMessage;

  const SeatReleaseResult({
    required this.success,
    required this.seatNumber,
    this.errorMessage,
  });
}

/// Snapshot of held seats for a trip.
class HeldSeatsSnapshot {
  final List<int> seatNumbers;
  final List<int> remainingSeconds;
  final bool holdsAllowed;
  final int holdTtlMinutes;

  const HeldSeatsSnapshot({
    required this.seatNumbers,
    required this.remainingSeconds,
    required this.holdsAllowed,
    required this.holdTtlMinutes,
  });

  factory HeldSeatsSnapshot.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final heldList = data['held_seats'] as List<dynamic>? ?? [];
    final seats = <int>[];
    final secs = <int>[];
    for (final h in heldList) {
      if (h is Map) {
        seats.add((h['seat_number'] ?? 0) as int);
        secs.add((h['remaining_seconds'] ?? 0) as int);
      }
    }
    return HeldSeatsSnapshot(
      seatNumbers: seats,
      remainingSeconds: secs,
      holdsAllowed: data['holds_allowed'] == true,
      holdTtlMinutes: (data['hold_ttl_minutes'] ?? 8) as int,
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

  /// List all published layouts (no auth — guest browsing).
  Future<List<Map<String, dynamic>>> fetchPublishedLayouts() async {
    try {
      final response = await _api.get(
        '/bus-fleet/absolute-layouts/public',
        queryParams: {'per_page': '50'},
        requiresAuth: false,
      );
      final data = _safeMap(response);
      final list = data['data'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Fetch a published bus layout with live booking + hold status.
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

  // ── HOLD SEAT (Phase 2) ──────────────────────────

  /// Reserve a seat for checkout (8-minute TTL).
  Future<SeatHoldResult> holdSeat({
    required String busId,
    required String tripId,
    required int seatNumber,
    int? ttlMinutes,
  }) async {
    try {
      final body = <String, dynamic>{
        'bus_id': busId,
        'trip_id': tripId,
        'seat_number': seatNumber,
      };
      if (ttlMinutes != null) body['ttl_minutes'] = ttlMinutes;

      final response = await _api.post('/bus-fleet/bookings/hold', body: body);
      final json = _safeMap(response);

      if (json['success'] != true) {
        return SeatHoldResult.failure(
          json['message']?.toString() ?? 'Failed to hold seat',
        );
      }
      return SeatHoldResult.fromJson(json);
    } catch (e) {
      final msg = _humanizeError(e);
      // Detect 409 conflict
      if (msg.contains('just claimed') || msg.contains('already booked')) {
        return SeatHoldResult.failure(
          'Seat $seatNumber was just claimed by another passenger.',
        );
      }
      return SeatHoldResult.failure(msg);
    }
  }

  /// Confirm a held seat — process payment, finalize booking.
  Future<SeatBookingResult> confirmHold({
    required String holdToken,
    required String paymentMethod,
    required double ticketPrice,
    String? voucherCode,
    String? busOwnerId,
  }) async {
    try {
      final body = <String, dynamic>{
        'payment_method': paymentMethod,
        'ticket_price': ticketPrice,
      };
      if (voucherCode != null && voucherCode.isNotEmpty) {
        body['voucher_code'] = voucherCode;
      }
      if (busOwnerId != null && busOwnerId.isNotEmpty) {
        body['bus_owner_id'] = busOwnerId;
      }

      final response = await _api.post(
        '/bus-fleet/bookings/$holdToken/confirm',
        body: body,
      );
      final json = _safeMap(response);

      if (json['success'] != true) {
        return SeatBookingResult.failure(
          json['message']?.toString() ?? 'Confirmation failed',
        );
      }
      return SeatBookingResult.fromJson(json);
    } catch (e) {
      final msg = _humanizeError(e);
      if (msg.contains('expired')) {
        return SeatBookingResult.failure(
          'Your hold has expired. Please select the seat again.',
        );
      }
      return SeatBookingResult.failure(msg);
    }
  }

  /// Release a held seat (user cancels).
  Future<SeatReleaseResult> releaseHold(String holdToken) async {
    try {
      final response = await _api.delete(
        '/bus-fleet/bookings/$holdToken/release',
      );
      final json = _safeMap(response);
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return SeatReleaseResult(
        success: json['success'] == true,
        seatNumber: (data['seat_number'] ?? 0) as int,
        errorMessage: json['message']?.toString(),
      );
    } catch (_) {
      // Non-fatal — server cron will clean up anyway
      return const SeatReleaseResult(success: false, seatNumber: 0);
    }
  }

  /// Fetch currently held seats for a trip (public).
  Future<HeldSeatsSnapshot> fetchHeldSeats(String tripId) async {
    try {
      final response = await _api.get(
        '/bus-fleet/bookings/held/$tripId',
        requiresAuth: false,
      );
      final json = _safeMap(response);
      return HeldSeatsSnapshot.fromJson(json);
    } catch (_) {
      return const HeldSeatsSnapshot(
        seatNumbers: [],
        remainingSeconds: [],
        holdsAllowed: false,
        holdTtlMinutes: 8,
      );
    }
  }

  // ── BOOK SEAT (instant, existing) ──────────────────

  /// Book a seat with payment method (instant, no hold).
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
    if (msg.contains('just claimed') || msg.contains('already booked')) {
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

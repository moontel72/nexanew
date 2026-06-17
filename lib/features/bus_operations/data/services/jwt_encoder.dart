// NEXATRACE — JWT ENCODER SERVICE
// =================================
// Lightweight JWT (HS256) token encoder for secure
// ETA share links. Uses the crypto package for HMAC-SHA256
// signing — no external dependencies needed.
//
// Tokens contain: trip_id, bus_id, exp (expiry),
// and optional passenger_name.
//
// MODULE: 8V — Secure Encrypted ETA Link Exporter

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service for generating and verifying JWT share tokens.
class JwtEncoder {
  final String _secret;

  /// Create a JWT encoder with a signing secret.
  /// In production, use a server-generated secret.
  JwtEncoder({String? secret})
    : _secret = secret ?? 'nexatrace_eta_share_secret_2026';

  /// Encode a JWT token with the given payload.
  /// Returns the full JWT string: header.payload.signature
  String encode(Map<String, dynamic> payload) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    final headerB64 = _base64UrlEncode(utf8.encode(jsonEncode(header)));
    final payloadB64 = _base64UrlEncode(utf8.encode(jsonEncode(payload)));

    final signatureInput = '$headerB64.$payloadB64';
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(signatureInput));
    final signatureB64 = _base64UrlEncode(digest.bytes);

    return '$headerB64.$payloadB64.$signatureB64';
  }

  /// Decode and verify a JWT token.
  /// Returns the payload if valid, or null if invalid/expired.
  Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final headerB64 = parts[0];
      final payloadB64 = parts[1];
      final signatureB64 = parts[2];

      // Verify signature
      final signatureInput = '$headerB64.$payloadB64';
      final hmac = Hmac(sha256, utf8.encode(_secret));
      final digest = hmac.convert(utf8.encode(signatureInput));
      final expectedSig = _base64UrlEncode(digest.bytes);

      if (signatureB64 != expectedSig) return null;

      // Decode payload
      final payloadJson = utf8.decode(_base64UrlDecode(payloadB64));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

      // Check expiry
      final exp = payload['exp'] as int?;
      if (exp != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now > exp) return null; // expired
      }

      return payload;
    } catch (_) {
      return null;
    }
  }

  /// Generate a share token for a bus trip.
  /// The token expires after [expiryHours] hours (default 24).
  String generateEtaShareToken({
    required String tripId,
    String? busId,
    String? passengerName,
    int expiryHours = 24,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = now + (expiryHours * 3600);

    return encode({
      'trip_id': tripId,
      'bus_id': busId ?? '',
      'passenger': passengerName ?? 'Guest',
      'exp': exp,
      'iat': now,
      'type': 'eta_share',
    });
  }

  /// Build a shareable tracking URL from a JWT token.
  String buildShareUrl(String token, {String? baseUrl}) {
    final host = baseUrl ?? 'https://nexatrace.com';
    return '$host/track/$token';
  }

  // ── Base64URL helpers ──

  static String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static List<int> _base64UrlDecode(String str) {
    // Add padding back
    var padded = str;
    while (padded.length % 4 != 0) {
      padded += '=';
    }
    return base64Url.decode(padded);
  }
}

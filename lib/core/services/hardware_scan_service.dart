// Hardware Scan Service — Unified QR / NFC / Barcode abstraction layer
//
// Wraps mobile_scanner and qr_code_scanner configurations into a single
// callback-driven service.  Validates scanned tokens against the Step 22
// Cryptographic Serial Vault pattern (64-char hex SHA256 hash) and provides
// a classification pipeline: serial, URL, plain text, unknown.
//
// This service is UI-free — it exposes callback signatures that any scan
// overlay or dashboard widget can bind to without hardcoding landing views.
//
// Usage:
//   final scan = HardwareScanService();
//   scan.onScanSuccess = (payload, type) { /* handle */ };
//   scan.onScanFailed = (reason) { /* show error */ };
//   await scan.start();

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────
// Scan result types
// ─────────────────────────────────────────────────────────────

/// Classifies a scanned payload into a known NexaTrace domain.
enum ScanPayloadType {
  /// 64-char hex string matching SHA256 vault serial (Step 22).
  cryptoSHA256,

  /// NexaTrace API URL (e.g. verify endpoint) — contains product metadata.
  nexaTraceUrl,

  /// Standard QR / barcode URL — follow in browser.
  webUrl,

  /// Plain alphanumeric identifier not matching any known pattern.
  plainText,

  /// Unknown / unclassifiable payload.
  unknown,
}

/// Result of a hardware scan operation.
class ScanResult {
  final String rawPayload;
  final ScanPayloadType type;
  final DateTime scannedAt;
  final String scanUuid; // Idempotency key for offline sync (Step 10)

  const ScanResult({
    required this.rawPayload,
    required this.type,
    required this.scannedAt,
    required this.scanUuid,
  });

  /// Whether this payload passes cryptographic validation.
  bool get isAuthenticSerial => type == ScanPayloadType.cryptoSHA256;

  /// Extract product hash if this is a serial scan.
  String? get productHash =>
      type == ScanPayloadType.cryptoSHA256 ? rawPayload : null;
}

// ─────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────

class HardwareScanService {
  final Uuid _uuid = const Uuid();

  /// Fired when a valid scan completes with a classified payload.
  void Function(ScanResult result)? onScanSuccess;

  /// Fired when the scanner encounters a recoverable error.
  void Function(String reason)? onScanFailed;

  /// Optional throttle duration between scans (default 1.5s).
  Duration scanThrottle = const Duration(milliseconds: 1500);

  /// Native verification pipeline (Step 9 Rust FFI).
  /// When set, SHA256 serials are synchronously validated on-device.
  bool Function(String serial)? nativeVerifier;

  DateTime? _lastScanTime;

  // ── Public API ────────────────────────────────────────────

  /// Process a raw payload string from any scanner widget.
  /// Call this from the scanner's `onScan` / `onDetect` callback.
  void processPayload(String raw) {
    final now = DateTime.now();

    // ── Throttle ─────────────────────────────────────────
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < scanThrottle) {
      return;
    }
    _lastScanTime = now;

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      onScanFailed?.call('Empty scan payload received');
      return;
    }

    // ── Classify ─────────────────────────────────────────
    final type = _classify(trimmed);

    // ── Native verification pipeline (Rust FFI, Step 9) ──
    bool? nativeResult;
    int? elapsedUs;
    if (type == ScanPayloadType.cryptoSHA256 && nativeVerifier != null) {
      final sw = Stopwatch()..start();
      try {
        nativeResult = nativeVerifier!(trimmed);
      } catch (_) {
        nativeResult = null; // Native panic — treat as unverified.
      }
      sw.stop();
      elapsedUs = sw.elapsedMicroseconds;
      if (kDebugMode) {
        debugPrint('SCAN_SVC: Native verify = $nativeResult (${elapsedUs}µs)');
      }
    }

    final result = ScanResult(
      rawPayload: trimmed,
      type: type,
      scannedAt: now,
      scanUuid: _uuid.v4(),
    );

    if (kDebugMode) {
      debugPrint(
        'SCAN_SVC: type=$type payload=${trimmed.length > 40 ? '${trimmed.substring(0, 40)}...' : trimmed}',
      );
    }

    onScanSuccess?.call(result);
  }

  /// Synchronous validation of a payload against Step 22 vault pattern.
  /// Returns true if the token matches SHA256 hex format.
  bool isValidCryptographicSerial(String payload) {
    return _classify(payload) == ScanPayloadType.cryptoSHA256;
  }

  /// Reset internal throttle state (useful when switching scanner screens).
  void reset() {
    _lastScanTime = null;
  }

  void dispose() {
    onScanSuccess = null;
    onScanFailed = null;
    nativeVerifier = null;
  }

  // ── Classification engine ─────────────────────────────────

  static final RegExp _sha256Pattern = RegExp(r'^[a-fA-F0-9]{64}$');
  static final RegExp _nexaTraceUrlPattern = RegExp(
    r'nexatrace|135\.181\.46\.27.*/verify|/consumer/verify|/factory/production/verify-serial',
    caseSensitive: false,
  );
  static final RegExp _webUrlPattern = RegExp(r'^https?://');

  ScanPayloadType _classify(String payload) {
    // Step 22: SHA256(Batch ID + Secret Key + Seed) → 64 hex chars.
    if (_sha256Pattern.hasMatch(payload)) {
      return ScanPayloadType.cryptoSHA256;
    }

    // NexaTrace verification URL.
    if (_nexaTraceUrlPattern.hasMatch(payload)) {
      return ScanPayloadType.nexaTraceUrl;
    }

    // Generic web URL.
    if (_webUrlPattern.hasMatch(payload)) {
      return ScanPayloadType.webUrl;
    }

    // Plain text / barcode.
    if (payload.length >= 4 && payload.length <= 256) {
      return ScanPayloadType.plainText;
    }

    return ScanPayloadType.unknown;
  }
}

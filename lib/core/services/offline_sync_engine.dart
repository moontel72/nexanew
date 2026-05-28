// Offline Sync Engine — Local transactional queue with idempotent flush
//
// Stores pending API mutations (scans, handshakes, location updates) in a
// Hive box when the device is offline.  When connectivity returns, flushes
// the queue sequentially via NexaTraceApiClient, purging records on success
// and preserving them on failure for retry.
//
// Backend integration: POST /api/v1/sync/submit (Step 10) with UUID idempotency.
//
// Schema (stored as Map in Hive — zero code-gen required):
//   {
//     'id': String,           // UUID v4 idempotency key (Step 10)
//     'endpoint': String,     // Target panel route (e.g. /api/v1/sync/submit)
//     'payloadJson': String,  // JSON-serialized request body
//     'timestamp': String,    // ISO 8601 creation time
//     'retryCount': int,      // Number of failed flush attempts
//   }
//
// Usage:
//   final engine = OfflineSyncEngine();
//   await engine.init();
//   engine.enqueue(endpoint: '/api/v1/sync/submit', payload: {...});
//   // Engine auto-flushes when connectivity returns.

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/core/network/api_client_v2.dart';

// ─────────────────────────────────────────────────────────────
// Sync Record
// ─────────────────────────────────────────────────────────────

/// Lightweight value object for a queued offline mutation.
/// Stored as a Map in Hive — zero code generation required.
class SyncRecord {
  final String id;
  final String endpoint;
  final String payloadJson;
  final DateTime timestamp;
  final int retryCount;

  const SyncRecord({
    required this.id,
    required this.endpoint,
    required this.payloadJson,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'endpoint': endpoint,
    'payloadJson': payloadJson,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncRecord.fromMap(Map<dynamic, dynamic> map) => SyncRecord(
    id: map['id']?.toString() ?? '',
    endpoint: map['endpoint']?.toString() ?? '',
    payloadJson: map['payloadJson']?.toString() ?? '{}',
    timestamp:
        DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
    retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
  );

  SyncRecord copyWith({int? retryCount}) => SyncRecord(
    id: id,
    endpoint: endpoint,
    payloadJson: payloadJson,
    timestamp: timestamp,
    retryCount: retryCount ?? this.retryCount,
  );
}

// ─────────────────────────────────────────────────────────────
// Engine
// ─────────────────────────────────────────────────────────────

class OfflineSyncEngine {
  static const String _boxName = 'nexatrace_sync_queue';
  static const int _maxRetries = 5;
  static const Duration _flushInterval = Duration(seconds: 3);

  final Uuid _uuid = const Uuid();
  Box<Map>? _box;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _flushTimer;
  bool _isFlushing = false;
  bool _isInitialized = false;

  /// Fired when a record is successfully flushed.
  void Function(String recordId)? onRecordFlushed;

  /// Fired when a record exhausts retries and is discarded.
  void Function(SyncRecord record, String error)? onRecordFailed;

  // ── Lifecycle ─────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    _box = await Hive.openBox<Map>(_boxName);
    _isInitialized = true;

    // Listen for connectivity changes.
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) _startPeriodicFlush();
    });

    // If already online, flush immediately.
    final current = await Connectivity().checkConnectivity();
    if (current.any((r) => r != ConnectivityResult.none)) {
      _startPeriodicFlush();
    }

    if (kDebugMode) {
      debugPrint('SYNC_ENGINE: Initialized — ${_box!.length} pending records');
    }
  }

  /// Enqueue a mutation for later flush.
  /// Returns the UUID idempotency key for client-side dedup.
  String enqueue({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) {
    if (_box == null) {
      throw StateError('OfflineSyncEngine not initialized. Call init() first.');
    }

    final id = _uuid.v4();
    final record = SyncRecord(
      id: id,
      endpoint: endpoint,
      payloadJson: jsonEncode(payload),
      timestamp: DateTime.now(),
    );

    _box!.add(record.toMap());

    if (kDebugMode) {
      debugPrint(
        'SYNC_ENGINE: Enqueued $id → $endpoint (total: ${_box!.length})',
      );
    }

    return id;
  }

  /// Get count of pending records.
  int get pendingCount => _box?.length ?? 0;

  /// Whether records are pending.
  bool get hasPending => pendingCount > 0;

  /// Force an immediate flush (e.g. on manual "Sync Now" tap).
  Future<void> flushNow() async {
    if (_isFlushing) return;
    await _flushQueue();
  }

  void dispose() {
    _flushTimer?.cancel();
    _connectivitySub?.cancel();
    _isInitialized = false;
    _box = null;
  }

  // ── Internal flush loop ───────────────────────────────────

  void _startPeriodicFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushQueue());
  }

  Future<void> _flushQueue() async {
    if (_isFlushing || _box == null || _box!.isEmpty) return;
    _isFlushing = true;

    try {
      // Process records sequentially to preserve order.
      while (_box!.isNotEmpty) {
        final key = _box!.keys.first;
        final raw = _box!.get(key);
        if (raw == null) {
          await _box!.delete(key);
          continue;
        }

        final record = SyncRecord.fromMap(raw);
        final success = await _sendRecord(record);

        if (success) {
          await _box!.delete(key);
          onRecordFlushed?.call(record.id);
          if (kDebugMode) {
            debugPrint(
              'SYNC_ENGINE: Flushed ${record.id} (remaining: ${_box!.length - 1})',
            );
          }
        } else {
          // Increment retry count or discard if exhausted.
          final newCount = record.retryCount + 1;
          if (newCount >= _maxRetries) {
            await _box!.delete(key);
            onRecordFailed?.call(
              record,
              'Max retries ($_maxRetries) exhausted',
            );
            if (kDebugMode) {
              debugPrint(
                'SYNC_ENGINE: Discarded ${record.id} after $_maxRetries retries',
              );
            }
          } else {
            await _box!.put(key, record.copyWith(retryCount: newCount).toMap());
            break; // Stop on first failure — retry next cycle.
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SYNC_ENGINE: Flush error — $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<bool> _sendRecord(SyncRecord record) async {
    try {
      final client = NexaTraceApiClient.instance;
      final body = jsonDecode(record.payloadJson) as Map<String, dynamic>;

      // Inject the idempotency key into the payload.
      body['client_uuid'] = record.id;

      final response = await client.post(
        record.endpoint,
        body: body,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // Backend returns 200/201/202 for successful sync.
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException {
      // Network failure during flush — will retry next cycle.
      return false;
    } catch (e) {
      if (kDebugMode)
        debugPrint('SYNC_ENGINE: Send error for ${record.id} — $e');
      return false;
    }
  }
}

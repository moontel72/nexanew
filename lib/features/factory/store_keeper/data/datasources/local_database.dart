import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:trace_odd/features/factory/store_keeper/data/models/local_scan_model.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  static const String _sessionsBox = 'scan_sessions';
  static const String _recordsBox = 'scan_records';
  static const String _syncsBox = 'pending_syncs';

  final Uuid _uuid = const Uuid();
  Box<ScanSessionModel>? _sessionBox;
  Box<LocalScanModel>? _recordBox;
  Box<PendingSyncModel>? _syncBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
    _registerAdapters();
    _sessionBox = await Hive.openBox<ScanSessionModel>(_sessionsBox);
    _recordBox = await Hive.openBox<LocalScanModel>(_recordsBox);
    _syncBox = await Hive.openBox<PendingSyncModel>(_syncsBox);
    _initialized = true;
    if (kDebugMode)
      debugPrint(
        'LOCAL_DB: ${_recordBox?.length} records, ${_sessionBox?.length} sessions, ${_syncBox?.length} pending syncs',
      );
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(20))
      Hive.registerAdapter(LocalScanModelAdapter());
    if (!Hive.isAdapterRegistered(21))
      Hive.registerAdapter(ScanSessionModelAdapter());
    if (!Hive.isAdapterRegistered(22))
      Hive.registerAdapter(PendingSyncModelAdapter());
  }

  void _ensureInitialized() {
    if (!_initialized)
      throw StateError('LocalDatabase not initialized. Call init() first.');
  }

  Future<String> createSession({String? storeKeeperId}) async {
    _ensureInitialized();
    final sid = _uuid.v4();
    await _sessionBox!.put(
      sid,
      ScanSessionModel(
        sessionId: sid,
        startTime: DateTime.now(),
        storeKeeperId: storeKeeperId,
      ),
    );
    return sid;
  }

  Future<void> closeSession(String sessionId) async {
    _ensureInitialized();
    final s = _sessionBox!.get(sessionId);
    if (s != null)
      await _sessionBox!.put(
        sessionId,
        ScanSessionModel(
          sessionId: s.sessionId,
          startTime: s.startTime,
          endTime: DateTime.now(),
          synced: s.synced,
          scanCount: s.scanCount,
          storeKeeperId: s.storeKeeperId,
        ),
      );
  }

  List<ScanSessionModel> getSessions({bool? synced}) {
    _ensureInitialized();
    final all = _sessionBox!.values.toList();
    return synced != null ? all.where((s) => s.synced == synced).toList() : all;
  }

  ScanSessionModel? getSession(String id) {
    _ensureInitialized();
    return _sessionBox!.get(id);
  }

  Future<LocalScanModel> createRecord({
    required String code,
    required String codeType,
    String? productId,
    String? packetId,
    String? cartonId,
    String? bundleId,
    String? rackCode,
    String? sectionName,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    final record = LocalScanModel(
      id: _uuid.v4(),
      code: code,
      codeType: codeType,
      productId: productId,
      packetId: packetId,
      cartonId: cartonId,
      bundleId: bundleId,
      rackCode: rackCode,
      sectionName: sectionName,
      scannedAt: DateTime.now(),
      synced: false,
      sessionId: sessionId,
      metadata: metadata,
    );
    await _recordBox!.put(record.id, record);
    if (sessionId != null) {
      final s = _sessionBox!.get(sessionId);
      if (s != null)
        await _sessionBox!.put(
          sessionId,
          ScanSessionModel(
            sessionId: s.sessionId,
            startTime: s.startTime,
            endTime: s.endTime,
            synced: s.synced,
            scanCount: s.scanCount + 1,
            storeKeeperId: s.storeKeeperId,
          ),
        );
    }
    return record;
  }

  LocalScanModel? getRecord(String id) {
    _ensureInitialized();
    return _recordBox!.get(id);
  }

  List<LocalScanModel> getRecords({
    String? codeType,
    String? sessionId,
    bool? synced,
    DateTime? from,
    DateTime? to,
  }) {
    _ensureInitialized();
    Iterable<LocalScanModel> records = _recordBox!.values;
    if (codeType != null)
      records = records.where((r) => r.codeType == codeType);
    if (sessionId != null)
      records = records.where((r) => r.sessionId == sessionId);
    if (synced != null) records = records.where((r) => r.synced == synced);
    if (from != null) records = records.where((r) => r.scannedAt.isAfter(from));
    if (to != null) records = records.where((r) => r.scannedAt.isBefore(to));
    return records.toList();
  }

  List<LocalScanModel> getUnsyncedRecords() => getRecords(synced: false);
  Future<void> updateRecord(LocalScanModel record) async {
    _ensureInitialized();
    await _recordBox!.put(record.id, record);
  }

  Future<void> markRecordSynced(String id) async {
    _ensureInitialized();
    final r = _recordBox!.get(id);
    if (r != null) await _recordBox!.put(id, r.copyWith(synced: true));
  }

  Future<void> markRecordsSynced(List<String> ids) async {
    for (final id in ids) await markRecordSynced(id);
  }

  Future<void> deleteRecord(String id) async {
    _ensureInitialized();
    await _recordBox!.delete(id);
  }

  Future<int> clearSyncedRecords({Duration? olderThan}) async {
    _ensureInitialized();
    final cutoff = DateTime.now().subtract(
      olderThan ?? const Duration(days: 7),
    );
    final td = <String>[];
    for (final e in _recordBox!.toMap().entries) {
      if (e.value.synced && e.value.scannedAt.isBefore(cutoff)) td.add(e.key);
    }
    await _recordBox!.deleteAll(td);
    return td.length;
  }

  int get recordCount {
    _ensureInitialized();
    return _recordBox!.length;
  }

  int get todayScanCount {
    _ensureInitialized();
    final ts = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return _recordBox!.values.where((r) => r.scannedAt.isAfter(ts)).length;
  }

  Future<String> addPendingSync({
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    _ensureInitialized();
    final id = _uuid.v4();
    await _syncBox!.put(
      id,
      PendingSyncModel(
        id: id,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  List<PendingSyncModel> getPendingSyncs() {
    _ensureInitialized();
    return _syncBox!.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  int get pendingSyncCount {
    _ensureInitialized();
    return _syncBox!.length;
  }

  Future<void> updatePendingSync(
    String id, {
    int? retryCount,
    String? errorMessage,
  }) async {
    _ensureInitialized();
    final s = _syncBox!.get(id);
    if (s != null)
      await _syncBox!.put(
        id,
        PendingSyncModel(
          id: s.id,
          operation: s.operation,
          payload: s.payload,
          createdAt: s.createdAt,
          retryCount: retryCount ?? s.retryCount,
          lastRetryAt: DateTime.now(),
          errorMessage: errorMessage,
        ),
      );
  }

  Future<void> removePendingSync(String id) async {
    _ensureInitialized();
    await _syncBox!.delete(id);
  }

  Future<void> clearAllPendingSyncs() async {
    _ensureInitialized();
    await _syncBox!.clear();
  }

  List<LocalScanModel> getHierarchy(String bundleId) {
    _ensureInitialized();
    final result = <LocalScanModel>[];
    final bundle =
        _recordBox!.get(bundleId) ??
        _recordBox!.values.firstWhere(
          (r) =>
              r.codeType == 'bundle' &&
              (r.bundleId == bundleId || r.code == bundleId),
          orElse: () => _recordBox!.values.first,
        );
    result.add(bundle);
    final cartons = _recordBox!.values
        .where((r) => r.codeType == 'carton' && r.bundleId == bundleId)
        .toList();
    result.addAll(cartons);
    for (final c in cartons) {
      final packets = _recordBox!.values
          .where((r) => r.codeType == 'packet' && r.cartonId == c.id)
          .toList();
      result.addAll(packets);
      for (final p in packets) {
        result.addAll(
          _recordBox!.values.where(
            (r) => r.codeType == 'unit' && r.packetId == p.id,
          ),
        );
      }
    }
    return result;
  }

  Future<void> dispose() async {
    await _sessionBox?.close();
    await _recordBox?.close();
    await _syncBox?.close();
    _initialized = false;
  }

  Future<void> clearAll() async {
    _ensureInitialized();
    await _sessionBox!.clear();
    await _recordBox!.clear();
    await _syncBox!.clear();
  }
}

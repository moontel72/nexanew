import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/datasources/local_database.dart';
import 'package:nexatrace_system/features/factory/store_keeper/data/models/local_scan_model.dart';
import 'package:nexatrace_system/features/factory/store_keeper/domain/entities/scan_record.dart';
import 'package:nexatrace_system/features/factory/store_keeper/domain/usecases/sync_data_usecase.dart';

class StoreKeeperRepository {
  final LocalDatabase _localDb;
  final ApiService _apiService;
  final Connectivity _connectivity;

  StoreKeeperRepository({
    LocalDatabase? localDb,
    ApiService? apiService,
    Connectivity? connectivity,
  }) : _localDb = localDb ?? LocalDatabase(),
       _apiService = apiService ?? ApiService(),
       _connectivity = connectivity ?? Connectivity();

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<ScanRecord> scanCode(
    String code, {
    String? codeType,
    String? sessionId,
  }) async {
    final localRecord = await _localDb.createRecord(
      code: code,
      codeType: codeType ?? _inferCodeType(code),
      sessionId: sessionId,
    );
    final online = await isOnline;
    if (online) {
      try {
        await _apiService.post(
          '/factory/store-keepers/scan',
          body: {
            'code': code,
            'code_type': localRecord.codeType,
            'scanned_at': localRecord.scannedAt.toIso8601String(),
            'session_id': sessionId,
          },
        );
        await _localDb.markRecordSynced(localRecord.id);
      } catch (e) {
        await _localDb.addPendingSync(
          operation: 'scan',
          payload: {
            'record_id': localRecord.id,
            'code': code,
            'code_type': localRecord.codeType,
            'scanned_at': localRecord.scannedAt.toIso8601String(),
            'session_id': sessionId,
          },
        );
      }
    } else {
      await _localDb.addPendingSync(
        operation: 'scan',
        payload: {
          'record_id': localRecord.id,
          'code': code,
          'code_type': localRecord.codeType,
          'scanned_at': localRecord.scannedAt.toIso8601String(),
          'session_id': sessionId,
        },
      );
    }
    return _toDomain(localRecord);
  }

  Future<bool> linkBundleToCarton(String bundleId, String cartonId) async {
    await _localDb.createRecord(
      code: cartonId,
      codeType: 'carton',
      bundleId: bundleId,
    );
    return _tryRemoteOrQueue('link_bundle_carton', {
      'bundle_id': bundleId,
      'carton_id': cartonId,
    });
  }

  Future<bool> linkCartonToPacket(String cartonId, String packetId) async {
    await _localDb.createRecord(
      code: packetId,
      codeType: 'packet',
      cartonId: cartonId,
    );
    return _tryRemoteOrQueue('link_carton_packet', {
      'carton_id': cartonId,
      'packet_id': packetId,
    });
  }

  Future<bool> linkUnitToPacket(
    String packetId,
    String unitId,
    String productId,
    int quantity,
  ) async {
    await _localDb.createRecord(
      code: unitId,
      codeType: 'unit',
      packetId: packetId,
      productId: productId,
      metadata: {'quantity': quantity},
    );
    return _tryRemoteOrQueue('link_unit_packet', {
      'packet_id': packetId,
      'unit_id': unitId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<bool> allocateToRack(
    String codeId,
    String rackCode,
    String sectionName,
  ) async {
    final existing = _localDb.getRecord(codeId);
    if (existing != null)
      await _localDb.updateRecord(
        existing.copyWith(rackCode: rackCode, sectionName: sectionName),
      );
    return _tryRemoteOrQueue('allocate_rack', {
      'code_id': codeId,
      'rack_code': rackCode,
      'section_name': sectionName,
    });
  }

  Future<bool> _tryRemoteOrQueue(
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final online = await isOnline;
    if (online) {
      try {
        await _apiService.post(_endpointForOperation(operation), body: payload);
        return true;
      } catch (e) {
        await _localDb.addPendingSync(operation: operation, payload: payload);
      }
    } else {
      await _localDb.addPendingSync(operation: operation, payload: payload);
    }
    return true;
  }

  List<ScanRecord> getUnsyncedRecords() =>
      _localDb.getUnsyncedRecords().map(_toDomain).toList();

  Future<SyncResult> syncAll() async {
    final online = await isOnline;
    if (!online)
      return SyncResult(
        syncedCount: 0,
        failedCount: 0,
        conflictCount: 0,
        syncedRecords: [],
        errors: ['Device offline.'],
      );
    int synced = 0, failed = 0, conflicts = 0;
    final syncedRecords = <ScanRecord>[];
    final errors = <String>[];
    final pendingSyncs = _localDb.getPendingSyncs();
    for (final pending in pendingSyncs) {
      try {
        await _apiService.post(
          _endpointForOperation(pending.operation),
          body: pending.payload,
        );
        await _localDb.removePendingSync(pending.id);
        synced++;
      } catch (e) {
        failed++;
        errors.add('${pending.operation}: $e');
        await _localDb.updatePendingSync(
          pending.id,
          retryCount: pending.retryCount + 1,
          errorMessage: e.toString(),
        );
      }
    }
    final unsynced = _localDb.getUnsyncedRecords();
    for (final record in unsynced) {
      try {
        await _apiService.post(
          '/factory/store-keepers/scan',
          body: {
            'code': record.code,
            'code_type': record.codeType,
            'scanned_at': record.scannedAt.toIso8601String(),
            'product_id': record.productId,
            'packet_id': record.packetId,
            'carton_id': record.cartonId,
            'bundle_id': record.bundleId,
            'rack_code': record.rackCode,
            'section_name': record.sectionName,
            'session_id': record.sessionId,
          },
        );
        await _localDb.markRecordSynced(record.id);
        syncedRecords.add(_toDomain(record));
        synced++;
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('409') || errStr.contains('conflict')) {
          conflicts++;
          await _localDb.markRecordSynced(record.id);
          errors.add(
            'Conflict: ${record.code} — server wins (first-scan-wins)',
          );
        } else {
          failed++;
          errors.add('Failed: ${record.code}: $e');
        }
      }
    }
    return SyncResult(
      syncedCount: synced,
      failedCount: failed,
      conflictCount: conflicts,
      syncedRecords: syncedRecords,
      errors: errors,
    );
  }

  int getTodayScanCount() => _localDb.todayScanCount;
  int getPendingSyncCount() => _localDb.pendingSyncCount;
  int getLinkedItemsCount() => _localDb
      .getRecords()
      .where(
        (r) =>
            r.codeType == 'carton' ||
            r.codeType == 'packet' ||
            r.codeType == 'unit',
      )
      .length;

  HierarchyNode getHierarchy(String bundleId) {
    final records = _localDb.getHierarchy(bundleId);
    return _buildTree(records);
  }

  HierarchyNode _buildTree(List<LocalScanModel> records) {
    final root = records.firstWhere(
      (r) => r.codeType == 'bundle',
      orElse: () => records.first,
    );
    final children = <HierarchyNode>[];
    if (root.codeType == 'bundle') {
      for (final carton in records.where(
        (r) => r.codeType == 'carton' && r.bundleId == root.id,
      )) {
        final packetNodes = records
            .where((r) => r.codeType == 'packet' && r.cartonId == carton.id)
            .map(
              (p) => HierarchyNode(
                id: p.id,
                code: p.code,
                codeType: 'packet',
                label: 'Packet: ${p.code}',
                children: records
                    .where((r) => r.codeType == 'unit' && r.packetId == p.id)
                    .map(
                      (u) => HierarchyNode(
                        id: u.id,
                        code: u.code,
                        codeType: 'unit',
                        label: 'Unit: ${u.code}',
                        metadata: u.metadata,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();
        children.add(
          HierarchyNode(
            id: carton.id,
            code: carton.code,
            codeType: 'carton',
            label: 'Carton: ${carton.code}',
            children: packetNodes,
          ),
        );
      }
    }
    return HierarchyNode(
      id: root.id,
      code: root.code,
      codeType: root.codeType,
      label: '${root.codeType.toUpperCase()}: ${root.code}',
      children: children,
    );
  }

  ScanRecord _toDomain(LocalScanModel m) => ScanRecord(
    id: m.id,
    code: m.code,
    codeType: m.codeType,
    productId: m.productId,
    packetId: m.packetId,
    cartonId: m.cartonId,
    bundleId: m.bundleId,
    rackCode: m.rackCode,
    sectionName: m.sectionName,
    scannedAt: m.scannedAt,
    synced: m.synced,
    sessionId: m.sessionId,
    metadata: m.metadata,
  );
  String _inferCodeType(String code) {
    final original = code.toUpperCase();

    final stripped = original.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // 0. Check ORIGINAL for single-letter prefixes (C-, P-, U-, B-)
    if (original.startsWith('C-')) return 'carton';
    if (original.startsWith('P-')) return 'packet';
    if (original.startsWith('U-')) return 'unit';
    if (original.startsWith('B-')) return 'bundle';

    // 1. Explicit prefix checks on stripped version
    if (stripped.startsWith('BND') || stripped.startsWith('BUN'))
      return 'bundle';
    if (stripped.startsWith('CTN') || stripped.startsWith('CAR'))
      return 'carton';
    if (stripped.startsWith('PKT') || stripped.startsWith('PAC'))
      return 'packet';
    if (stripped.startsWith('UNT') || stripped.startsWith('UNI')) return 'unit';

    // 2. UUID detection (32 hex chars)
    if (stripped.length == 32 && RegExp(r'^[0-9A-F]{32}$').hasMatch(stripped)) {
      return 'code';
    }

    // 3. Default
    return 'code';
  }

  String _endpointForOperation(String op) {
    switch (op) {
      case 'scan':
        return '/factory/store-keepers/scan';
      case 'link_bundle_carton':
        return '/factory/store-keeper-bundles/{bundleId}/link-carton';
      case 'link_carton_packet':
        return '/factory/store-keeper-bundles/{bundleId}/link-packet';
      case 'link_unit_packet':
        return '/factory/store-keeper-bundles/{bundleId}/link-unit';
      case 'allocate_rack':
        return '/factory/store-keepers/allocate';
      default:
        return '/factory/store-keepers/scan';
    }
  }
}

import 'package:nexatrace_system/features/factory/admin/data/datasources/codes_remote_datasource.dart';
import 'package:nexatrace_system/features/factory/admin/domain/repositories/codes_repository.dart';
import 'package:nexatrace_system/shared/models/code/bundle_code_model.dart';
import 'package:nexatrace_system/shared/models/code/carton_code_model.dart';
import 'package:nexatrace_system/shared/models/code/packet_code_model.dart';
import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';

class CodesRepositoryImpl implements CodesRepository {
  final CodesRemoteDatasource _remote;

  CodesRepositoryImpl({required CodesRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    throw const FormatException('Expected JSON object');
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const [];
  }

  @override
  Future<void> generateBundleCodes({
    required int count,
    String? batchId,
    required int cartonsPerBundle,
  }) async {
    await _remote.generateBundleCodes(
      count: count,
      batchId: batchId,
      cartonsPerBundle: cartonsPerBundle,
    );
  }

  @override
  Future<List<BundleCodeModel>> getBundleCodes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _remote.listBundleCodes(page: page, limit: limit);
    final data = _asMap(_asMap(res)['data']);
    final items = _asList(data['bundle_codes']);

    return items
        .whereType<Map>()
        .map((e) => BundleCodeModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> generateCartonCodes({
    required int count,
    String? batchId,
    required int packetCount,
    int? totalUnits,
    int? unitsPerPacket,
  }) async {
    await _remote.generateCartonCodes(
      count: count,
      batchId: batchId,
      packetCount: packetCount,
      totalUnits: totalUnits,
      unitsPerPacket: unitsPerPacket,
    );
  }

  @override
  Future<List<CartonCodeModel>> getCartonCodes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _remote.listCartonCodes(page: page, limit: limit);
    final data = _asMap(_asMap(res)['data']);
    final items = _asList(data['carton_codes']);

    return items
        .whereType<Map>()
        .map((e) => CartonCodeModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> generatePacketCodes({
    required int count,
    String? batchId,
    int? unitCount,
  }) async {
    await _remote.generatePacketCodes(
      count: count,
      batchId: batchId,
      unitCount: unitCount,
    );
  }

  @override
  Future<List<PacketCodeModel>> getPacketCodes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _remote.listPacketCodes(page: page, limit: limit);
    final data = _asMap(_asMap(res)['data']);
    final items = _asList(data['packet_codes']);

    return items
        .whereType<Map>()
        .map((e) => PacketCodeModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> generateUnitCodes({
    required int count,
    String? batchId,
  }) async {
    await _remote.generateUnitCodes(
      count: count,
      batchId: batchId,
    );
  }

  @override
  Future<List<UnitCodeModel>> getUnitCodes({
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
  }) async {
    final res = await _remote.listUnitCodes(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );

    final data = _asMap(_asMap(res)['data']);
    final items = _asList(data['unit_codes']);

    return items
        .whereType<Map>()
        .map((e) => UnitCodeModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<int> linkUnitCodesToProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.linkUnitCodesToProduct(
      productId: productId,
      unitCodeIds: unitCodeIds,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = _asMap(_asMap(res)['data']);
    return int.tryParse((data['linked_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<int> publishUnitCodesForProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.publishUnitCodesForProduct(
      productId: productId,
      unitCodeIds: unitCodeIds,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = _asMap(_asMap(res)['data']);
    return int.tryParse((data['published_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<int> linkBundleCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.linkBundleCodeToProduct(
      codeId: codeId,
      productId: productId,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = _asMap(_asMap(res)['data']);
    return int.tryParse((data['linked_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<int> publishBundleCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.publishBundleCodes(
      codeIds: codeIds,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = _asMap(_asMap(res)['data']);
    return int.tryParse((data['published_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<String> downloadBundleCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _remote.downloadBundleCodes(
      codeIds: codeIds,
      format: format,
      includeQrCodes: includeQrCodes,
      includeBarcodes: includeBarcodes,
      includeInternationalCodes: includeInternationalCodes,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return (data['file_path'] ?? '').toString();
  }

  @override
  Future<int> linkCartonCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.linkCartonCodeToProduct(
      codeId: codeId,
      productId: productId,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return int.tryParse((data['linked_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<int> publishCartonCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.publishCartonCodes(
      codeIds: codeIds,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return int.tryParse((data['published_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<String> downloadCartonCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _remote.downloadCartonCodes(
      codeIds: codeIds,
      format: format,
      includeQrCodes: includeQrCodes,
      includeBarcodes: includeBarcodes,
      includeInternationalCodes: includeInternationalCodes,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return (data['file_path'] ?? '').toString();
  }

  @override
  Future<int> linkPacketCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.linkPacketCodeToProduct(
      codeId: codeId,
      productId: productId,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return int.tryParse((data['linked_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<int> publishPacketCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _remote.publishPacketCodes(
      codeIds: codeIds,
      productBatchNumber: productBatchNumber,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      warrantyMonths: warrantyMonths,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return int.tryParse((data['published_count'] ?? 0).toString()) ?? 0;
  }

  @override
  Future<String> downloadPacketCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _remote.downloadPacketCodes(
      codeIds: codeIds,
      format: format,
      includeQrCodes: includeQrCodes,
      includeBarcodes: includeBarcodes,
      includeInternationalCodes: includeInternationalCodes,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return (data['file_path'] ?? '').toString();
  }

  @override
  Future<String> downloadUnitCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _remote.downloadUnitCodes(
      codeIds: codeIds,
      format: format,
      includeQrCodes: includeQrCodes,
      includeBarcodes: includeBarcodes,
      includeInternationalCodes: includeInternationalCodes,
    );

    final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final downloadUrl = (data['download_url'] ?? '').toString().trim();
    if (downloadUrl.isNotEmpty) return downloadUrl;
    return (data['file_path'] ?? '').toString();
  }
}

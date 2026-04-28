import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:flutter/foundation.dart';

class CodesRemoteDatasource {
  final ApiService _api;

  CodesRemoteDatasource({required ApiService apiService}) : _api = apiService;

  Future<void> deleteCode({required String type, required String id}) async {
    await _api.delete('/codes/$type/$id');
  }

  Future<Map<String, dynamic>> generateUnitCodes({
    required int count,
    String? batchId,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.unitCodes}/generate',
      data: {
        'count': count,
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> listUnitCodes({
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'DEBUG: listUnitCodes endpoint=${ApiEndpoints.unitCodes}/list page=$page limit=$limit search=$search status=$status',
      );
    }
    final res = await _api.get(
      '${ApiEndpoints.unitCodes}/list',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> generatePacketCodes({
    required int count,
    String? batchId,
    int? unitCount,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.packetCodes}/generate',
      data: {
        'count': count,
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
        if (unitCount != null) 'unit_count': unitCount,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> listPacketCodes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.get(
      '${ApiEndpoints.packetCodes}/list',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> generateCartonCodes({
    required int count,
    String? batchId,
    int? packetCount,
    int? totalUnits,
    int? unitsPerPacket,
    String? codeFormat,
    String? prefix,
  }) async {
    // If a specific format is provided, use the format-specific endpoint
    if (codeFormat != null && codeFormat.isNotEmpty) {
      final res = await _api.post(
        ApiEndpoints.generateCartonCodesByFormat(codeFormat),
        data: {
          'count': count,
          if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
          if (packetCount != null) 'packet_count': packetCount,
          if (totalUnits != null) 'total_units': totalUnits,
          if (unitsPerPacket != null) 'units_per_packet': unitsPerPacket,
          if (prefix != null && prefix.isNotEmpty) 'prefix': prefix,
        },
      );
      return (res as Map).cast<String, dynamic>();
    }
    // Fallback to the generic endpoint
    final res = await _api.post(
      '${ApiEndpoints.cartonCodes}/generate',
      data: {
        'count': count,
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
        if (packetCount != null) 'packet_count': packetCount,
        if (totalUnits != null) 'total_units': totalUnits,
        if (unitsPerPacket != null) 'units_per_packet': unitsPerPacket,
        if (prefix != null && prefix.isNotEmpty) 'prefix': prefix,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> listCartonCodes({
    int page = 1,
    int limit = 50,
    String? codeFormat,
  }) async {
    // If a specific format is provided, use the format-specific endpoint
    if (codeFormat != null && codeFormat.isNotEmpty) {
      final res = await _api.get(
        ApiEndpoints.listCartonCodesByFormat(codeFormat),
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      return (res as Map).cast<String, dynamic>();
    }
    // Fallback to the generic endpoint
    final res = await _api.get(
      '${ApiEndpoints.cartonCodes}/list',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> generateBundleCodes({
    required int count,
    String? batchId,
    int? cartonsPerBundle,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.bundleCodes}/generate',
      data: {
        'count': count,
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
        if (cartonsPerBundle != null) 'cartons_per_bundle': cartonsPerBundle,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> listBundleCodes({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.get(
      '${ApiEndpoints.bundleCodes}/list',
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> linkUnitCodesToProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.linkCodesToProduct.replaceFirst('{id}', productId),
      data: {
        'code_ids': unitCodeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishUnitCodesForProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'DEBUG: publishUnitCodesForProduct productId=$productId codeIds=${unitCodeIds.length} batch=$productBatchNumber mfg=$manufacturingDate exp=$expiryDate warrantyMonths=$warrantyMonths',
      );
    }
    final res = await _api.post(
      ApiEndpoints.publishProductCodes.replaceFirst('{id}', productId),
      data: {
        'code_ids': unitCodeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    if (kDebugMode) {
      debugPrint('DEBUG: publishUnitCodesForProduct response=$res');
    }
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> linkBundleCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.linkBundleCodes,
      data: {
        'code_id': codeId,
        'product_id': productId,
        'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishBundleCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishBundleCodes,
      data: {
        'code_ids': codeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishBundleCodesByBatch({
    required String batchId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishBundleCodes,
      data: {'batch_id': batchId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadBundleCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadBundleCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> linkCartonCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.linkCartonCodes,
      data: {
        'code_id': codeId,
        'product_id': productId,
        'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishCartonCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishCartonCodes,
      data: {
        'code_ids': codeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishCartonCodesByBatch({
    required String batchId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishCartonCodes,
      data: {'batch_id': batchId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadCartonCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadCartonCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> linkPacketCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.linkPacketCodes,
      data: {
        'code_id': codeId,
        'product_id': productId,
        'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishPacketCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishPacketCodes,
      data: {
        'code_ids': codeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishPacketCodesByBatch({
    required String batchId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishPacketCodes,
      data: {'batch_id': batchId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadPacketCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadPacketCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadUnitCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadUnitCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }
}

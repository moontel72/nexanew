import 'package:trace_odd/core/constants/api_endpoints.dart';
import 'package:trace_odd/core/services/api_service.dart';
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
    String? codeFormat,
    String? productId,
    String? prefix,
    String? manufacturingDate,
    String? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.unitCodes}/generate',
      data: {
        'count': count,
        'code_format': codeFormat ?? 'qr',
        'product_id': productId ?? '',
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
        if (prefix != null && prefix.isNotEmpty) 'prefix': prefix,
        if (manufacturingDate != null) 'manufacturing_date': manufacturingDate,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
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
    String? codeFormat,
    String? prefix,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.packetCodes}/generate',
      data: {
        'count': count,
        'code_format': codeFormat ?? 'qr',
        if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
        if (unitCount != null) 'unit_count': unitCount,
        if (prefix != null && prefix.isNotEmpty) 'prefix': prefix,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> listPacketCodes({
    int page = 1,
    int limit = 50,
    String? codeFormat,
  }) async {
    final res = await _api.get(
      '${ApiEndpoints.packetCodes}/list',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (codeFormat != null) 'code_format': codeFormat,
      },
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
    if (codeFormat != null && codeFormat.isNotEmpty) {
      final res = await _api.get(
        ApiEndpoints.listCartonCodesByFormat(codeFormat),
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      return (res as Map).cast<String, dynamic>();
    }
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

  Future<Map<String, dynamic>> publishCartonCodesByBatchAndFormat({
    required String batchId,
    required String codeFormat,
    required int count,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishCartonCodes,
      data: {'batch_id': batchId, 'code_format': codeFormat, 'count': count},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteCartonBatch({
    required String batchId,
    required String codeFormat,
  }) async {
    final res = await _api.post(
      ApiEndpoints.deleteCartonBatch,
      data: {'batch_id': batchId, 'code_format': codeFormat},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadCartonCodes({
    required List<String> codeIds,
    required String format,
    String? codeFormat,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadCartonCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        if (codeFormat != null && codeFormat.isNotEmpty)
          'code_format': codeFormat,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadCartonBatch({
    required String batchId,
    required String codeFormat,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadCartonCodes,
      data: {
        'format': format,
        'batch_id': batchId,
        'code_format': codeFormat,
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

  Future<Map<String, dynamic>> publishPacketCodesByBatchAndFormat({
    required String batchId,
    required String codeFormat,
    required int count,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishPacketCodes,
      data: {'batch_id': batchId, 'code_format': codeFormat, 'count': count},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deletePacketBatch({
    required String batchId,
    required String codeFormat,
  }) async {
    final res = await _api.post(
      ApiEndpoints.deletePacketBatch,
      data: {'batch_id': batchId, 'code_format': codeFormat},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadPacketCodes({
    required List<String> codeIds,
    required String format,
    String? codeFormat,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadPacketCodes,
      data: {
        'format': format,
        'code_ids': codeIds,
        if (codeFormat != null && codeFormat.isNotEmpty)
          'code_format': codeFormat,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadPacketBatch({
    required String batchId,
    required String codeFormat,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final res = await _api.post(
      ApiEndpoints.downloadPacketCodes,
      data: {
        'format': format,
        'batch_id': batchId,
        'code_format': codeFormat,
        'include_qr_codes': includeQrCodes,
        'include_barcodes': includeBarcodes,
        'include_international_codes': includeInternationalCodes,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> publishUnitCodesByBatchAndFormat({
    required String batchId,
    required String codeFormat,
    required int count,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.unitCodes}/publish',
      data: {'batch_id': batchId, 'code_format': codeFormat, 'count': count},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deleteUnitBatch({
    required String batchId,
    required String codeFormat,
  }) async {
    final res = await _api.post(
      '${ApiEndpoints.unitCodes}/batch/delete',
      data: {'batch_id': batchId, 'code_format': codeFormat},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> downloadUnitCodes({
    required List<String> codeIds,
    required String format,
    String? batchId,
    String? codeFormat,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  }) async {
    final body = <String, dynamic>{
      'format': format,
      if (codeIds.isNotEmpty) 'code_ids': codeIds,
      if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
      if (codeFormat != null && codeFormat.isNotEmpty)
        'code_format': codeFormat,
      'include_qr_codes': includeQrCodes,
      'include_barcodes': includeBarcodes,
      'include_international_codes': includeInternationalCodes,
    };
    final res = await _api.post(ApiEndpoints.downloadUnitCodes, data: body);
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> linkUnitsToPacket({
    required String packetId,
    required String productId,
    required String batchId,
    required int quantity,
  }) async {
    final res = await _api.post(
      ApiEndpoints.aggregationLinkUnits,
      data: {
        'packet_id': packetId,
        'product_id': productId,
        'batch_id': batchId,
        'quantity': quantity,
      },
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> unlinkUnitsFromPacket({
    required String packetId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.aggregationUnlinkUnits,
      data: {'packet_id': packetId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> fetchAvailableUnits({
    required String productId,
    required String batchId,
  }) async {
    final res = await _api.get(
      ApiEndpoints.aggregationAvailableUnits,
      queryParameters: {'product_id': productId, 'batch_id': batchId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> fetchAvailableBatches({
    required String productId,
  }) async {
    final res = await _api.get(
      ApiEndpoints.aggregationAvailableBatches,
      queryParameters: {'product_id': productId},
    );
    return (res as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> fetchBundleInsights(String bundleId) async {
    final res = await _api.get(ApiEndpoints.bundleInsights(bundleId));
    return (res as Map).cast<String, dynamic>();
  }
}

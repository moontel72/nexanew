import 'package:nexatrace_system/shared/models/code/unit_code_model.dart';
import 'package:nexatrace_system/shared/models/code/packet_code_model.dart';
import 'package:nexatrace_system/shared/models/code/carton_code_model.dart';
import 'package:nexatrace_system/shared/models/code/bundle_code_model.dart';

abstract class CodesRepository {
  Future<void> generateBundleCodes({
    required int count,
    String? batchId,
    int? cartonsPerBundle,
  });

  Future<List<BundleCodeModel>> getBundleCodes({int page = 1, int limit = 50});

  Future<void> generateCartonCodes({
    required int count,
    String? batchId,
    int? packetCount,
    int? totalUnits,
    int? unitsPerPacket,
    String? codeFormat,
    String? prefix,
  });

  Future<List<CartonCodeModel>> getCartonCodes({
    int page = 1,
    int limit = 50,
    String? codeFormat,
  });

  Future<void> generatePacketCodes({
    required int count,
    String? batchId,
    int? unitCount,
  });

  Future<List<PacketCodeModel>> getPacketCodes({int page = 1, int limit = 50});

  Future<void> generateUnitCodes({required int count, String? batchId});

  Future<List<UnitCodeModel>> getUnitCodes({
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
  });

  Future<int> linkUnitCodesToProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<int> publishUnitCodesForProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<int> linkBundleCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<int> publishBundleCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<String> downloadBundleCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  });

  Future<int> linkCartonCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<int> publishCartonCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<String> downloadCartonCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  });

  Future<int> publishCartonBatch({
    required String batchId,
    required String codeFormat,
    required int count,
  });

  Future<int> deleteCartonBatch({
    required String batchId,
    required String codeFormat,
  });

  Future<String> downloadCartonBatch({
    required String batchId,
    required String codeFormat,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  });

  Future<int> linkPacketCodeToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<int> publishPacketCodes({
    required List<String> codeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  });

  Future<String> downloadPacketCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  });

  Future<String> downloadUnitCodes({
    required List<String> codeIds,
    required String format,
    bool includeQrCodes = true,
    bool includeBarcodes = true,
    bool includeInternationalCodes = true,
  });
}

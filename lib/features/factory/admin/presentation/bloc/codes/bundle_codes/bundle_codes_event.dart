part of 'bundle_codes_bloc.dart';

@freezed
abstract class BundleCodesEvent with _$BundleCodesEvent {
  const factory BundleCodesEvent.load() = LoadBundleCodes;
  const factory BundleCodesEvent.generate(BundleCodeGenerationRequest request) = GenerateBundleCodes;
  const factory BundleCodesEvent.delete(String codeId) = DeleteBundleCode;
  const factory BundleCodesEvent.deleteBatch(List<String> codeIds) = DeleteBundleCodeBatch;
  const factory BundleCodesEvent.linkToProduct({
    required String codeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) = LinkBundleCodeToProduct;
  const factory BundleCodesEvent.publish(String codeId) = PublishBundleCode;
  const factory BundleCodesEvent.deactivate(String codeId) = DeactivateBundleCode;
  const factory BundleCodesEvent.search(String query) = SearchBundleCodes;
  const factory BundleCodesEvent.filter({
    CodeStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? minCartonCount,
    int? maxCartonCount,
    String? batchId,
  }) = FilterBundleCodes;
  const factory BundleCodesEvent.export({
    @Default(ExportFormat.csv) ExportFormat format,
    List<String>? codeIds,
    @Default(true) bool includeQrCodes,
    @Default(true) bool includeBarcodes,
    @Default(true) bool includeInternationalCodes,
  }) = ExportBundleCodes;
  const factory BundleCodesEvent.select(String codeId) = SelectBundleCode;
  const factory BundleCodesEvent.clearSelection() = ClearSelection;
  const factory BundleCodesEvent.refresh() = RefreshBundleCodes;
  const factory BundleCodesEvent.loadMore() = LoadMoreBundleCodes;
  const factory BundleCodesEvent.update(BundleCodeModel updatedCode) = UpdateBundleCode;
  const factory BundleCodesEvent.viewDetails(String codeId) = ViewBundleCodeDetails;
}

enum ExportFormat { csv, excel, pdf, json }
enum DownloadFormat { pdf, excel, zip }
enum PrintTemplate { defaultTemplate, withQrCodes, withBarcodes, withBoth, labels }

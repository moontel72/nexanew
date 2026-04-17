part of 'carton_codes_bloc.dart';

@freezed
abstract class CartonCodesEvent with _$CartonCodesEvent {
  const factory CartonCodesEvent.load() = LoadCartonCodes;
  const factory CartonCodesEvent.generate(CartonCodeGenerationRequest request) = GenerateCartonCodes;
  const factory CartonCodesEvent.delete(String cartonCodeId) = DeleteCartonCode;
  const factory CartonCodesEvent.deleteBatch(List<String> cartonCodeIds) = DeleteCartonCodeBatch;
  const factory CartonCodesEvent.linkToProduct({
    required String cartonCodeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) = LinkCartonCodeToProduct;
  const factory CartonCodesEvent.publish(String cartonCodeId) = PublishCartonCode;
  const factory CartonCodesEvent.deactivate(String cartonCodeId, String reason) = DeactivateCartonCode;
  const factory CartonCodesEvent.search(String query) = SearchCartonCodes;
  const factory CartonCodesEvent.filter({
    CodeStatus? status,
    String? bundleCode,
    DateTime? startDate,
    DateTime? endDate,
    String? cartonType,
    String? condition,
  }) = FilterCartonCodes;
  const factory CartonCodesEvent.export(List<String> cartonCodeIds, String format) = ExportCartonCodes;
  const factory CartonCodesEvent.select(String cartonCodeId, bool isSelected) = SelectCartonCode;
  const factory CartonCodesEvent.clearSelection() = ClearSelection;
  const factory CartonCodesEvent.refresh() = RefreshCartonCodes;
  const factory CartonCodesEvent.seal(String cartonCodeId, String sealedBy) = SealCarton;
  const factory CartonCodesEvent.updateInspection(
    String cartonCodeId,
    String condition,
    String inspectionNotes,
  ) = UpdateCartonInspection;
  const factory CartonCodesEvent.updateProperties({
    required String cartonCodeId,
    double? weight,
    String? dimensions,
    String? temperatureRequirements,
    String? handlingInstructions,
  }) = UpdateCartonProperties;
}

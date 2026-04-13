part of 'packet_codes_bloc.dart';

@freezed
abstract class PacketCodesEvent with _$PacketCodesEvent {
  const factory PacketCodesEvent.load() = LoadPacketCodes;
  const factory PacketCodesEvent.generate(PacketCodeGenerationRequest request) = GeneratePacketCodes;
  const factory PacketCodesEvent.delete(String packetCodeId) = DeletePacketCode;
  const factory PacketCodesEvent.deleteBatch(List<String> packetCodeIds) = DeletePacketCodeBatch;
  const factory PacketCodesEvent.linkToProduct({
    required String packetCodeId,
    required String productId,
    required String productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) = LinkPacketCodeToProduct;
  const factory PacketCodesEvent.publish(String packetCodeId) = PublishPacketCode;
  const factory PacketCodesEvent.deactivate(String packetCodeId, String reason) = DeactivatePacketCode;
  const factory PacketCodesEvent.search(String query) = SearchPacketCodes;
  const factory PacketCodesEvent.filter({
    CodeStatus? status,
    String? cartonCode,
    DateTime? startDate,
    DateTime? endDate,
    String? packetType,
    String? condition,
  }) = FilterPacketCodes;
  const factory PacketCodesEvent.export(List<String> packetCodeIds, String format) = ExportPacketCodes;
  const factory PacketCodesEvent.select(String packetCodeId, bool isSelected) = SelectPacketCode;
  const factory PacketCodesEvent.clearSelection() = ClearSelection;
  const factory PacketCodesEvent.refresh() = RefreshPacketCodes;
  const factory PacketCodesEvent.seal(String packetCodeId, String sealedBy, {String? sealingMethod}) = SealPacket;
  const factory PacketCodesEvent.updateInspection(
    String packetCodeId,
    String condition,
    String inspectionNotes,
    bool hasTamperEvidence,
    bool hasChildSafety,
  ) = UpdatePacketInspection;
  const factory PacketCodesEvent.updateProperties({
    required String packetCodeId,
    double? weight,
    String? dimensions,
    String? packetType,
    String? material,
    String? sealingMethod,
  }) = UpdatePacketProperties;
  const factory PacketCodesEvent.addTamperEvidence(String packetCodeId) = AddTamperEvidence;
  const factory PacketCodesEvent.addChildSafetyFeatures(String packetCodeId) = AddChildSafetyFeatures;
  const factory PacketCodesEvent.addInstructions(String packetCodeId) = AddInstructions;
}

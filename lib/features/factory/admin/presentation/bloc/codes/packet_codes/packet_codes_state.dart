part of 'packet_codes_bloc.dart';

/// Packet Codes Status
enum PacketCodesStatus {
  initial,
  loading,
  loaded,
  generating,
  generated,
  deleting,
  deleted,
  linking,
  linked,
  publishing,
  published,
  deactivating,
  deactivated,
  sealing,
  sealed,
  inspecting,
  inspected,
  updating,
  updated,
  exporting,
  exported,
  error,
}

@freezed
abstract class PacketCodesState with _$PacketCodesState {
  const factory PacketCodesState({
    @Default(PacketCodesStatus.initial) PacketCodesStatus status,
    @Default([]) List<PacketCodeModel> packetCodes,
    @Default([]) List<PacketCodeModel> filteredPacketCodes,
    @Default({}) Set<String> selectedPacketCodeIds,
    @Default('') String searchQuery,
    CodeStatus? filterStatus,
    String? filterCartonCode,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterPacketType,
    String? filterCondition,
    @Default('') String filterCodeFormat,
    String? errorMessage,
    @Default(false) bool hasReachedMax,
    @Default(1) int currentPage,
    @Default(0) int totalCount,
    @Default(false) bool isLoadingMore,
    @Default(0) int generatedCount,
    DateTime? lastGeneratedAt,
    String? exportPath,
    @Default(false) bool isExporting,
  }) = _PacketCodesState;

  const PacketCodesState._();

  /// Get selected packet codes
  List<PacketCodeModel> get selectedPacketCodes {
    return packetCodes
        .where((packet) => selectedPacketCodeIds.contains(packet.id))
        .toList();
  }

  /// Get total selected units
  int get totalSelectedUnits {
    return selectedPacketCodes.fold(0, (sum, packet) => sum + packet.unitCount);
  }

  /// Get packet statistics
  Map<String, dynamic> get statistics {
    final totalPackets = packetCodes.length;
    final sealedPackets = packetCodes.where((p) => p.isSealed).length;
    final intactPackets = packetCodes
        .where((p) => p.condition == 'Intact')
        .length;
    final damagedPackets = packetCodes
        .where((p) => p.condition == 'Damaged')
        .length;
    final totalUnits = packetCodes.fold(0, (sum, p) => sum + p.unitCount);
    final tamperEvidencePackets = packetCodes
        .where((p) => p.hasTamperEvidence)
        .length;
    final childSafetyPackets = packetCodes
        .where((p) => p.hasChildSafety)
        .length;

    return {
      'totalPackets': totalPackets,
      'sealedPackets': sealedPackets,
      'intactPackets': intactPackets,
      'damagedPackets': damagedPackets,
      'totalUnits': totalUnits,
      'tamperEvidencePackets': tamperEvidencePackets,
      'childSafetyPackets': childSafetyPackets,
      'sealedPercentage': totalPackets > 0
          ? (sealedPackets / totalPackets * 100).round()
          : 0,
      'intactPercentage': totalPackets > 0
          ? (intactPackets / totalPackets * 100).round()
          : 0,
    };
  }

  /// Check if any packet is selected
  bool get hasSelection => selectedPacketCodeIds.isNotEmpty;

  /// Check if all packets are selected
  bool get allSelected {
    if (filteredPacketCodes.isEmpty) return false;
    return selectedPacketCodeIds.length == filteredPacketCodes.length;
  }
}

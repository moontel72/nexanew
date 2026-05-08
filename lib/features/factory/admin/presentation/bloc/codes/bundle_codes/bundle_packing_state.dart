// Non-freezed state file — avoids build_runner dependency
enum BundlePackingStatus {
  initial,
  loading,
  ready,
  submitting,
  submitted,
  error,
}

class FormatOption {
  final String value;
  final String displayName;
  const FormatOption({required this.value, required this.displayName});
}

class BatchOption {
  final String batchId;
  final String codeFormat;
  final int codeCount;
  final bool isPushed;
  const BatchOption({
    required this.batchId,
    required this.codeFormat,
    required this.codeCount,
    required this.isPushed,
  });
}

class CodeOption {
  final String id;
  final String code;
  final String status;
  const CodeOption({
    required this.id,
    required this.code,
    required this.status,
  });
}

class BundlePackingState {
  final BundlePackingStatus status;
  final List<FormatOption> cartonFormats;
  final List<FormatOption> packetFormats;
  final String? selectedCartonFormat;
  final List<BatchOption> cartonBatches;
  final BatchOption? selectedCartonBatch;
  final List<CodeOption> cartonCodes;
  final Set<String> selectedCartonCodeIds;
  final String? selectedPacketFormat;
  final List<BatchOption> packetBatches;
  final BatchOption? selectedPacketBatch;
  final List<CodeOption> packetCodes;
  final Set<String> selectedPacketCodeIds;
  final String? errorMessage;

  const BundlePackingState({
    this.status = BundlePackingStatus.initial,
    this.cartonFormats = const [],
    this.packetFormats = const [],
    this.selectedCartonFormat,
    this.cartonBatches = const [],
    this.selectedCartonBatch,
    this.cartonCodes = const [],
    this.selectedCartonCodeIds = const {},
    this.selectedPacketFormat,
    this.packetBatches = const [],
    this.selectedPacketBatch,
    this.packetCodes = const [],
    this.selectedPacketCodeIds = const {},
    this.errorMessage,
  });

  BundlePackingState copyWith({
    BundlePackingStatus? status,
    List<FormatOption>? cartonFormats,
    List<FormatOption>? packetFormats,
    String? selectedCartonFormat,
    List<BatchOption>? cartonBatches,
    BatchOption? selectedCartonBatch,
    List<CodeOption>? cartonCodes,
    Set<String>? selectedCartonCodeIds,
    String? selectedPacketFormat,
    List<BatchOption>? packetBatches,
    BatchOption? selectedPacketBatch,
    List<CodeOption>? packetCodes,
    Set<String>? selectedPacketCodeIds,
    String? errorMessage,
  }) {
    return BundlePackingState(
      status: status ?? this.status,
      cartonFormats: cartonFormats ?? this.cartonFormats,
      packetFormats: packetFormats ?? this.packetFormats,
      selectedCartonFormat: selectedCartonFormat ?? this.selectedCartonFormat,
      cartonBatches: cartonBatches ?? this.cartonBatches,
      selectedCartonBatch: selectedCartonBatch ?? this.selectedCartonBatch,
      cartonCodes: cartonCodes ?? this.cartonCodes,
      selectedCartonCodeIds:
          selectedCartonCodeIds ?? this.selectedCartonCodeIds,
      selectedPacketFormat: selectedPacketFormat ?? this.selectedPacketFormat,
      packetBatches: packetBatches ?? this.packetBatches,
      selectedPacketBatch: selectedPacketBatch ?? this.selectedPacketBatch,
      packetCodes: packetCodes ?? this.packetCodes,
      selectedPacketCodeIds:
          selectedPacketCodeIds ?? this.selectedPacketCodeIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

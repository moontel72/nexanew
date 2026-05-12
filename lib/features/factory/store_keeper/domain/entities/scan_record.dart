import 'package:equatable/equatable.dart';

class ScanRecord extends Equatable {
  final String id;
  final String code;
  final String codeType;
  final String? productId;
  final String? packetId;
  final String? cartonId;
  final String? bundleId;
  final String? rackCode;
  final String? sectionName;
  final DateTime scannedAt;
  final bool synced;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  const ScanRecord({
    required this.id,
    required this.code,
    required this.codeType,
    this.productId,
    this.packetId,
    this.cartonId,
    this.bundleId,
    this.rackCode,
    this.sectionName,
    required this.scannedAt,
    this.synced = false,
    this.sessionId,
    this.metadata,
  });

  ScanRecord copyWith({
    String? id,
    String? code,
    String? codeType,
    String? productId,
    String? packetId,
    String? cartonId,
    String? bundleId,
    String? rackCode,
    String? sectionName,
    DateTime? scannedAt,
    bool? synced,
    String? sessionId,
    Map<String, dynamic>? metadata,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      code: code ?? this.code,
      codeType: codeType ?? this.codeType,
      productId: productId ?? this.productId,
      packetId: packetId ?? this.packetId,
      cartonId: cartonId ?? this.cartonId,
      bundleId: bundleId ?? this.bundleId,
      rackCode: rackCode ?? this.rackCode,
      sectionName: sectionName ?? this.sectionName,
      scannedAt: scannedAt ?? this.scannedAt,
      synced: synced ?? this.synced,
      sessionId: sessionId ?? this.sessionId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    codeType,
    productId,
    packetId,
    cartonId,
    bundleId,
    rackCode,
    sectionName,
    scannedAt,
    synced,
    sessionId,
  ];
}

class ScanSession extends Equatable {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final bool synced;
  final int scanCount;
  final String? storeKeeperId;

  const ScanSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.synced = false,
    this.scanCount = 0,
    this.storeKeeperId,
  });
  @override
  List<Object?> get props => [
    sessionId,
    startTime,
    endTime,
    synced,
    scanCount,
    storeKeeperId,
  ];
}

class HierarchyNode extends Equatable {
  final String id;
  final String code;
  final String codeType;
  final String? label;
  final List<HierarchyNode> children;
  final Map<String, dynamic>? metadata;

  const HierarchyNode({
    required this.id,
    required this.code,
    required this.codeType,
    this.label,
    this.children = const [],
    this.metadata,
  });
  @override
  List<Object?> get props => [id, code, codeType, label, children];
}

enum CodeType {
  bundle,
  carton,
  packet,
  unit;

  static CodeType fromString(String value) => CodeType.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => CodeType.unit,
  );
  String get displayName => name[0].toUpperCase() + name.substring(1);
}

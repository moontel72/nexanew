import 'package:hive/hive.dart';
part 'local_scan_model.g.dart';

@HiveType(typeId: 20)
class LocalScanModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String code;
  @HiveField(2)
  final String codeType;
  @HiveField(3)
  final String? productId;
  @HiveField(4)
  final String? packetId;
  @HiveField(5)
  final String? cartonId;
  @HiveField(6)
  final String? bundleId;
  @HiveField(7)
  final String? rackCode;
  @HiveField(8)
  final String? sectionName;
  @HiveField(9)
  final DateTime scannedAt;
  @HiveField(10)
  final bool synced;
  @HiveField(11)
  final String? sessionId;
  @HiveField(12)
  final Map<String, dynamic>? metadata;

  LocalScanModel({
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

  factory LocalScanModel.fromJson(Map<String, dynamic> json) => LocalScanModel(
    id: json['id'] as String,
    code: json['code'] as String,
    codeType: json['codeType'] as String,
    productId: json['productId'] as String?,
    packetId: json['packetId'] as String?,
    cartonId: json['cartonId'] as String?,
    bundleId: json['bundleId'] as String?,
    rackCode: json['rackCode'] as String?,
    sectionName: json['sectionName'] as String?,
    scannedAt: json['scannedAt'] is DateTime
        ? json['scannedAt'] as DateTime
        : DateTime.parse(json['scannedAt'] as String),
    synced: json['synced'] as bool? ?? false,
    sessionId: json['sessionId'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'codeType': codeType,
    'productId': productId,
    'packetId': packetId,
    'cartonId': cartonId,
    'bundleId': bundleId,
    'rackCode': rackCode,
    'sectionName': sectionName,
    'scannedAt': scannedAt.toIso8601String(),
    'synced': synced,
    'sessionId': sessionId,
    'metadata': metadata,
  };

  LocalScanModel copyWith({
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
  }) => LocalScanModel(
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

@HiveType(typeId: 21)
class ScanSessionModel extends HiveObject {
  @HiveField(0)
  final String sessionId;
  @HiveField(1)
  final DateTime startTime;
  @HiveField(2)
  final DateTime? endTime;
  @HiveField(3)
  final bool synced;
  @HiveField(4)
  final int scanCount;
  @HiveField(5)
  final String? storeKeeperId;

  ScanSessionModel({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    this.synced = false,
    this.scanCount = 0,
    this.storeKeeperId,
  });
}

@HiveType(typeId: 22)
class PendingSyncModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String operation;
  @HiveField(2)
  final Map<String, dynamic> payload;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final int retryCount;
  @HiveField(5)
  final DateTime? lastRetryAt;
  @HiveField(6)
  final String? errorMessage;

  PendingSyncModel({
    required this.id,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
    this.errorMessage,
  });
}

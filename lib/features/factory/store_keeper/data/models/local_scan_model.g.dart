// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_scan_model.dart';

// **************************************************************************
// HiveAdapterGenerator
// **************************************************************************

class LocalScanModelAdapter extends TypeAdapter<LocalScanModel> {
  @override
  final int typeId = 20;

  @override
  LocalScanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalScanModel(
      id: fields[0] as String,
      code: fields[1] as String,
      codeType: fields[2] as String,
      productId: fields[3] as String?,
      packetId: fields[4] as String?,
      cartonId: fields[5] as String?,
      bundleId: fields[6] as String?,
      rackCode: fields[7] as String?,
      sectionName: fields[8] as String?,
      scannedAt: fields[9] as DateTime,
      synced: fields[10] as bool,
      sessionId: fields[11] as String?,
      metadata: fields[12] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalScanModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.codeType)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.packetId)
      ..writeByte(5)
      ..write(obj.cartonId)
      ..writeByte(6)
      ..write(obj.bundleId)
      ..writeByte(7)
      ..write(obj.rackCode)
      ..writeByte(8)
      ..write(obj.sectionName)
      ..writeByte(9)
      ..write(obj.scannedAt)
      ..writeByte(10)
      ..write(obj.synced)
      ..writeByte(11)
      ..write(obj.sessionId)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalScanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScanSessionModelAdapter extends TypeAdapter<ScanSessionModel> {
  @override
  final int typeId = 21;

  @override
  ScanSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanSessionModel(
      sessionId: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      synced: fields[3] as bool,
      scanCount: fields[4] as int,
      storeKeeperId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanSessionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.synced)
      ..writeByte(4)
      ..write(obj.scanCount)
      ..writeByte(5)
      ..write(obj.storeKeeperId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PendingSyncModelAdapter extends TypeAdapter<PendingSyncModel> {
  @override
  final int typeId = 22;

  @override
  PendingSyncModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSyncModel(
      id: fields[0] as String,
      operation: fields[1] as String,
      payload: fields[2] as Map<String, dynamic>,
      createdAt: fields[3] as DateTime,
      retryCount: fields[4] as int,
      lastRetryAt: fields[5] as DateTime?,
      errorMessage: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingSyncModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operation)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.lastRetryAt)
      ..writeByte(6)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSyncModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

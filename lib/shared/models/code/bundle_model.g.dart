// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BundleModel _$BundleModelFromJson(Map<String, dynamic> json) => _BundleModel(
  id: json['id'] as String,
  bundleCode: json['bundleCode'] as String,
  orderReference: json['orderReference'] as String? ?? '',
  totalCartons: (json['totalCartons'] as num?)?.toInt() ?? 0,
  totalPackets: (json['totalPackets'] as num?)?.toInt() ?? 0,
  locationStore: json['locationStore'] as String?,
  locationShelf: json['locationShelf'] as String?,
  status: json['status'] as String? ?? 'draft',
  packedAt: json['packedAt'] == null
      ? null
      : DateTime.parse(json['packedAt'] as String),
  notes: json['notes'] as String?,
  createdAt: _dateTimeFromJson(json['createdAt']),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => BundleItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BundleModelToJson(_BundleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bundleCode': instance.bundleCode,
      'orderReference': instance.orderReference,
      'totalCartons': instance.totalCartons,
      'totalPackets': instance.totalPackets,
      'locationStore': instance.locationStore,
      'locationShelf': instance.locationShelf,
      'status': instance.status,
      'packedAt': instance.packedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': _dateTimeToJson(instance.createdAt),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_BundleItemModel _$BundleItemModelFromJson(Map<String, dynamic> json) =>
    _BundleItemModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      cartonCodeId: json['cartonCodeId'] as String?,
      packetCodeId: json['packetCodeId'] as String?,
    );

Map<String, dynamic> _$BundleItemModelToJson(_BundleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'cartonCodeId': instance.cartonCodeId,
      'packetCodeId': instance.packetCodeId,
    };

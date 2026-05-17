// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bundle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BundleModel _$BundleModelFromJson(Map<String, dynamic> json) => _BundleModel(
  id: json['id'] as String,
  bundleCode: json['bundle_code'] as String,
  orderReference: json['order_reference'] as String? ?? '',
  totalCartons: (json['total_cartons'] as num?)?.toInt() ?? 0,
  totalPackets: (json['total_packets'] as num?)?.toInt() ?? 0,
  locationStore: json['location_store'] as String?,
  locationShelf: json['location_shelf'] as String?,
  status: json['status'] as String? ?? 'draft',
  packedAt: json['packed_at'] == null
      ? null
      : DateTime.parse(json['packed_at'] as String),
  notes: json['notes'] as String?,
  createdAt: _dateTimeFromJson(json['created_at']),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => BundleItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  storeKeeperName: json['store_keeper_name'] as String?,
);

Map<String, dynamic> _$BundleModelToJson(_BundleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bundle_code': instance.bundleCode,
      'order_reference': instance.orderReference,
      'total_cartons': instance.totalCartons,
      'total_packets': instance.totalPackets,
      'location_store': instance.locationStore,
      'location_shelf': instance.locationShelf,
      'status': instance.status,
      'packed_at': instance.packedAt?.toIso8601String(),
      'notes': instance.notes,
      'created_at': _dateTimeToJson(instance.createdAt),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'store_keeper_name': instance.storeKeeperName,
    };

_UnitItemModel _$UnitItemModelFromJson(Map<String, dynamic> json) =>
    _UnitItemModel(
      id: json['id'] as String,
      unitCode: json['unit_code'] as String?,
      productName: json['product_name'] as String?,
      packetCodeId: json['packet_code_id'] as String?,
    );

Map<String, dynamic> _$UnitItemModelToJson(_UnitItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_code': instance.unitCode,
      'product_name': instance.productName,
      'packet_code_id': instance.packetCodeId,
    };

_BundleItemModel _$BundleItemModelFromJson(Map<String, dynamic> json) =>
    _BundleItemModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      cartonCodeId: json['carton_code_id'] as String?,
      packetCodeId: json['packet_code_id'] as String?,
      productName: json['product_name'] as String?,
      codeDisplay: json['code_display'] as String?,
      units:
          (json['units'] as List<dynamic>?)
              ?.map((e) => UnitItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BundleItemModelToJson(_BundleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'carton_code_id': instance.cartonCodeId,
      'packet_code_id': instance.packetCodeId,
      'product_name': instance.productName,
      'code_display': instance.codeDisplay,
      'units': instance.units.map((e) => e.toJson()).toList(),
    };

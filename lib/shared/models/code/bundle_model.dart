import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'bundle_model.freezed.dart';
part 'bundle_model.g.dart';

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  final text = value.toString();
  if (text.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.parse(text);
}

String _dateTimeToJson(DateTime value) => value.toIso8601String();

/// Bundle Model
/// Minimal model for order-level bundles that aggregate cartons and packets
@freezed
@HiveType(typeId: 106)
abstract class BundleModel with _$BundleModel {
  const factory BundleModel({
    @HiveField(0) required String id,
    @HiveField(1) required String bundleCode,
    @HiveField(2) @Default('') String orderReference,
    @HiveField(3) @Default(0) int totalCartons,
    @HiveField(4) @Default(0) int totalPackets,
    @HiveField(5) String? locationStore,
    @HiveField(6) String? locationShelf,
    @HiveField(7) @Default('draft') String status,
    @HiveField(8) DateTime? packedAt,
    @HiveField(9) String? notes,
    @HiveField(10)
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required DateTime createdAt,
    @HiveField(11) @Default([]) List<BundleItemModel> items,
  }) = _BundleModel;

  factory BundleModel.fromJson(Map<String, dynamic> json) =>
      _$BundleModelFromJson(json);
}

/// Bundle Item Model
/// Represents a single carton or packet within a bundle
@freezed
@HiveType(typeId: 107)
abstract class BundleItemModel with _$BundleItemModel {
  const factory BundleItemModel({
    @HiveField(0) required String id,
    @HiveField(1) @Default('') String type, // 'carton' or 'packet'
    @HiveField(2) String? cartonCodeId,
    @HiveField(3) String? packetCodeId,
  }) = _BundleItemModel;

  factory BundleItemModel.fromJson(Map<String, dynamic> json) =>
      _$BundleItemModelFromJson(json);
}

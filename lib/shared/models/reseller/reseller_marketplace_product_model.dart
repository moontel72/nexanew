import 'package:freezed_annotation/freezed_annotation.dart';
import '../product/product_model.dart'; // for VolumeDiscountTier

part 'reseller_marketplace_product_model.freezed.dart';
part 'reseller_marketplace_product_model.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ResellerMarketplaceProductModel
    with _$ResellerMarketplaceProductModel {
  @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
  const factory ResellerMarketplaceProductModel({
    required String id,
    required String tenantId,
    required String factoryId,
    required String name,
    @Default('') String sku,
    @Default('') String category,
    @Default('') String productType,
    @Default('active') String status,
    @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
    @Default(0.0) double price,
    @Default('PKR') String currency,
    List<VolumeDiscountTier>? volumeDiscounts,
    @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
    double? promoDiscount,
    Map<String, dynamic>? metadata,
  }) = _ResellerMarketplaceProductModel;

  factory ResellerMarketplaceProductModel.fromJson(Map<String, dynamic> json) =>
      _$ResellerMarketplaceProductModelFromJson(json);

  static double? _fromJsonDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return parsed;
    }
    return null;
  }

  static dynamic _toJsonDouble(double? value) => value;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import '../product/product_model.dart'; // for VolumeDiscountTier

part 'reseller_marketplace_product_model.freezed.dart';
part 'reseller_marketplace_product_model.g.dart';

/// Safe double parser that handles String, int, double, and null values.
double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Non-nullable version — returns 0.0 on failure.
double _safeParseDoubleNN(dynamic value) => _safeParseDouble(value) ?? 0.0;

@Freezed(fromJson: true, toJson: true)
abstract class ResellerMarketplaceProductModel
    with _$ResellerMarketplaceProductModel {
  const factory ResellerMarketplaceProductModel({
    @Default('') String id,
    @Default('') String tenantId,
    @Default('') String factoryId,
    @Default('') String name,
    @Default('') String sku,
    @Default('') String category,
    @Default('') String productType,
    @Default('active') String status,
    @JsonKey(fromJson: _safeParseDoubleNN) @Default(0.0) double price,
    @Default('PKR') String currency,
    List<VolumeDiscountTier>? volumeDiscounts,
    @JsonKey(fromJson: _safeParseDouble) double? promoDiscount,
    Map<String, dynamic>? metadata,
    String? factoryName,
    String? factoryCity,
    String? factoryLogo,
    String? factoryStatus,
    @JsonKey(fromJson: _safeParseDouble) double? cartonPrice,
    @JsonKey(fromJson: _safeParseDouble) double? wholesalePrice,
    int? moq,
    int? bonusQuantity,
    int? bonusThreshold,
  }) = _ResellerMarketplaceProductModel;

  factory ResellerMarketplaceProductModel.fromJson(Map<String, dynamic> json) {
    final product = _$ResellerMarketplaceProductModelFromJson(json);
    return product;
  }
}

// ─────────────────────────────────────────────────────────────────────
// Extension getters
// ─────────────────────────────────────────────────────────────────────
extension ResellerMarketplaceProductModelExt
    on ResellerMarketplaceProductModel {
  String? get imageUrl => metadata?['image_url']?.toString();

  double get unitPrice {
    final v = metadata?['unit_price'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? price;
    return price;
  }

  bool get hasOffer =>
      (bonusQuantity != null && bonusThreshold != null) ||
      (promoDiscount != null && promoDiscount! > 0) ||
      (volumeDiscounts != null && volumeDiscounts!.isNotEmpty);
}

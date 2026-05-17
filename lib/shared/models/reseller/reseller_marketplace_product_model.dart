import 'package:freezed_annotation/freezed_annotation.dart';
import '../product/product_model.dart'; // for VolumeDiscountTier

part 'reseller_marketplace_product_model.freezed.dart';
part 'reseller_marketplace_product_model.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ResellerMarketplaceProductModel
    with _$ResellerMarketplaceProductModel {
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
    @Default(0.0)
    double price,
    @Default('PKR') String currency,
    List<VolumeDiscountTier>? volumeDiscounts,
    @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
    double? promoDiscount,
    Map<String, dynamic>? metadata,
    String? factoryName,
    String? factoryCity,
    String? factoryLogo,
    String? factoryStatus,
    @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
    double? cartonPrice,
    @JsonKey(fromJson: _fromJsonDouble, toJson: _toJsonDouble)
    double? wholesalePrice,
    int? moq,
    int? bonusQuantity,
    int? bonusThreshold,
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

// ─────────────────────────────────────────────────────────────────────
// Extension getters for computed / display convenience
// ─────────────────────────────────────────────────────────────────────
extension ResellerMarketplaceProductModelExt
    on ResellerMarketplaceProductModel {
  /// Product image URL (from metadata if not a top-level field).
  String? get imageUrl => metadata?['image_url']?.toString();

  /// Price per single unit (defaults to [price] if not set).
  double get unitPrice {
    final v = metadata?['unit_price'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? price;
    return price;
  }

  /// Whether this product has any active offer (bonus, promo, or volume discount).
  bool get hasOffer =>
      (bonusQuantity != null && bonusThreshold != null) ||
      (promoDiscount != null && promoDiscount! > 0) ||
      (volumeDiscounts != null && volumeDiscounts!.isNotEmpty);
}

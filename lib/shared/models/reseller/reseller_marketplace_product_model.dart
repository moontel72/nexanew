import 'package:freezed_annotation/freezed_annotation.dart';

part 'reseller_marketplace_product_model.freezed.dart';
part 'reseller_marketplace_product_model.g.dart';

@freezed
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
    @Default(0.0) double price,
    @Default('PKR') String currency,
    Map<String, dynamic>? metadata,
  }) = _ResellerMarketplaceProductModel;

  factory ResellerMarketplaceProductModel.fromJson(Map<String, dynamic> json) =>
      _$ResellerMarketplaceProductModelFromJson(json);
}


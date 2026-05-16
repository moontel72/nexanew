import 'package:freezed_annotation/freezed_annotation.dart';

part 'reseller_shop_model.freezed.dart';
part 'reseller_shop_model.g.dart';

@freezed
abstract class ResellerShopModel with _$ResellerShopModel {
  const factory ResellerShopModel({
    required String id,
    required String resellerId,
    required String name,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _ResellerShopModel;

  factory ResellerShopModel.fromJson(Map<String, dynamic> json) =>
      _$ResellerShopModelFromJson(json);
}

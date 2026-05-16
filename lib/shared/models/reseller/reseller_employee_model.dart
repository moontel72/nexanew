import 'package:freezed_annotation/freezed_annotation.dart';

part 'reseller_employee_model.freezed.dart';
part 'reseller_employee_model.g.dart';

enum ResellerEmployeeRole {
  shopManager,
  cashier,
  stockKeeper,
}

@freezed
abstract class ResellerEmployeeModel with _$ResellerEmployeeModel {
  const factory ResellerEmployeeModel({
    required String id,
    required String resellerId,
    required String shopId,
    required String name,
    required ResellerEmployeeRole role,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) = _ResellerEmployeeModel;

  factory ResellerEmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$ResellerEmployeeModelFromJson(json);
}

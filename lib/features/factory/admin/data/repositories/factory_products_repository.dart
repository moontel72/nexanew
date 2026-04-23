import 'package:nexatrace_system/core/constants/api_endpoints.dart';
import 'package:nexatrace_system/core/services/api_service.dart';
import 'package:nexatrace_system/shared/models/product/product_model.dart';

class FactoryProductsRepository {
  final ApiService _api;

  FactoryProductsRepository({required ApiService apiService})
    : _api = apiService;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    throw const FormatException('Expected JSON object');
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const [];
  }

  Future<List<ProductModel>> listProducts({String? search}) async {
    final res = await _api.get(
      ApiEndpoints.products,
      queryParameters: {
        'page': '1',
        'limit': '100',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final map = _asMap(res);
    final data = _asMap(map['data']);
    final items = _asList(data['products']);

    return items
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<ProductModel> createProduct({
    required String name,
    required String sku,
    String? description,
    String? category,
    required String productType,
    required bool requiresManufacturingDate,
    required bool requiresExpiryDate,
    required bool requiresWarranty,
    int? defaultWarrantyMonths,
    DateTime? defaultManufacturingDate,
    DateTime? defaultExpiryDate,
  }) async {
    final res = await _api.post(
      ApiEndpoints.createProduct,
      data: {
        'name': name,
        'sku': sku,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (category != null && category.isNotEmpty) 'category': category,
        'product_type': productType,
        'requires_manufacturing_date': requiresManufacturingDate,
        'requires_expiry_date': requiresExpiryDate,
        'requires_warranty': requiresWarranty,
        'default_warranty_months': ?defaultWarrantyMonths,
        'status': 'active',
        'metadata': {
          if (defaultManufacturingDate != null)
            'default_manufacturing_date': defaultManufacturingDate
                .toIso8601String()
                .split('T')
                .first,
          if (defaultExpiryDate != null)
            'default_expiry_date': defaultExpiryDate
                .toIso8601String()
                .split('T')
                .first,
        },
      },
    );

    final map = _asMap(res);
    final data = _asMap(map['data']);
    return ProductModel.fromJson(data);
  }

  Future<int> linkUnitCodesToProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.linkCodesToProduct.replaceFirst('{id}', productId),
      data: {
        'code_ids': unitCodeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );

    final map = _asMap(res);
    final data = _asMap(map['data']);
    return int.tryParse((data['linked_count'] ?? 0).toString()) ?? 0;
  }

  Future<int> publishUnitCodesForProduct({
    required String productId,
    required List<String> unitCodeIds,
    String? productBatchNumber,
    DateTime? manufacturingDate,
    DateTime? expiryDate,
    int? warrantyMonths,
  }) async {
    final res = await _api.post(
      ApiEndpoints.publishProductCodes.replaceFirst('{id}', productId),
      data: {
        'code_ids': unitCodeIds,
        if (productBatchNumber != null && productBatchNumber.isNotEmpty)
          'product_batch_number': productBatchNumber,
        if (manufacturingDate != null)
          'manufacturing_date': manufacturingDate
              .toIso8601String()
              .split('T')
              .first,
        if (expiryDate != null)
          'expiry_date': expiryDate.toIso8601String().split('T').first,
        if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      },
    );

    final map = _asMap(res);
    final data = _asMap(map['data']);
    return int.tryParse((data['published_count'] ?? 0).toString()) ?? 0;
  }
}

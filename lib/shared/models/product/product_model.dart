class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? description;
  final String? category;
  final String productType;
  final bool requiresManufacturingDate;
  final bool requiresExpiryDate;
  final bool requiresWarranty;
  final int? defaultWarrantyMonths;
  final String status;
  final DateTime? defaultManufacturingDate;
  final DateTime? defaultExpiryDate;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.description,
    required this.category,
    required this.productType,
    required this.requiresManufacturingDate,
    required this.requiresExpiryDate,
    required this.requiresWarranty,
    required this.defaultWarrantyMonths,
    required this.status,
    required this.defaultManufacturingDate,
    required this.defaultExpiryDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    final metadata = rawMetadata is Map ? rawMetadata.cast<String, dynamic>() : null;
    DateTime? parseDate(String? v) {
      if (v == null || v.isEmpty) return null;
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      productType: (json['product_type'] ?? json['productType'] ?? 'other')
          .toString(),
      requiresManufacturingDate:
          (json['requires_manufacturing_date'] ??
                  json['requiresManufacturingDate'] ??
                  false) ==
              true,
      requiresExpiryDate:
          (json['requires_expiry_date'] ?? json['requiresExpiryDate'] ?? false) ==
              true,
      requiresWarranty:
          (json['requires_warranty'] ?? json['requiresWarranty'] ?? false) ==
              true,
      defaultWarrantyMonths: (json['default_warranty_months'] ??
              json['defaultWarrantyMonths']) is int
          ? (json['default_warranty_months'] ?? json['defaultWarrantyMonths'])
              as int
          : int.tryParse(
              (json['default_warranty_months'] ?? json['defaultWarrantyMonths'] ??
                      '')
                  .toString(),
            ),
      status: (json['status'] ?? 'active').toString(),
      defaultManufacturingDate:
          parseDate(metadata?['default_manufacturing_date']?.toString()),
      defaultExpiryDate: parseDate(metadata?['default_expiry_date']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'category': category,
      'product_type': productType,
      'requires_manufacturing_date': requiresManufacturingDate,
      'requires_expiry_date': requiresExpiryDate,
      'requires_warranty': requiresWarranty,
      'default_warranty_months': defaultWarrantyMonths,
      'status': status,
      'metadata': {
        if (defaultManufacturingDate != null)
          'default_manufacturing_date':
              defaultManufacturingDate!.toIso8601String().split('T').first,
        if (defaultExpiryDate != null)
          'default_expiry_date':
              defaultExpiryDate!.toIso8601String().split('T').first,
      },
    };
  }
}


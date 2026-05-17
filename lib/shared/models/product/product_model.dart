class VolumeDiscountTier {
  final int minQuantity;
  final double discountPercent;

  const VolumeDiscountTier({
    required this.minQuantity,
    required this.discountPercent,
  });

  factory VolumeDiscountTier.fromJson(Map<String, dynamic> json) =>
      VolumeDiscountTier(
        minQuantity: json['min_qty'] ?? json['min_quantity'] ?? 0,
        discountPercent: (json['discount_percent'] ?? json['discount'] ?? 0)
            .toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'min_qty': minQuantity,
    'discount_percent': discountPercent,
  };
}

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

  // Commercial pricing
  final double? unitPrice;
  final double? cartonPrice;
  final double? wholesalePrice;
  final String currency;
  final String? discountType; // 'percentage' or 'fixed'
  final double? discountValue;
  final int moq; // minimum order quantity, default 1
  final bool marketplaceEnabled;
  final int? bonusQuantity;
  final int? bonusThreshold;
  final double? walletCredit;
  final String? promoCode;
  final double? promoDiscount;
  final List<String>? tags;
  final List<VolumeDiscountTier>? volumeDiscounts;

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
    // Commercial pricing
    this.unitPrice,
    this.cartonPrice,
    this.wholesalePrice,
    this.currency = 'NGN',
    this.discountType,
    this.discountValue,
    this.moq = 1,
    this.marketplaceEnabled = false,
    this.bonusQuantity,
    this.bonusThreshold,
    this.walletCredit,
    this.promoCode,
    this.promoDiscount,
    this.tags,
    this.volumeDiscounts,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    final metadata = rawMetadata is Map
        ? rawMetadata.cast<String, dynamic>()
        : null;
    DateTime? parseDate(String? v) {
      if (v == null || v.isEmpty) return null;
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }

    // Parse volume discounts list
    List<VolumeDiscountTier>? parseVolumeDiscounts(dynamic raw) {
      if (raw is List) {
        return raw
            .map(
              (e) => VolumeDiscountTier.fromJson(
                e is Map<String, dynamic> ? e : <String, dynamic>{},
              ),
            )
            .toList();
      }
      return null;
    }

    // Parse tags list
    List<String>? parseTags(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return null;
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
          (json['requires_expiry_date'] ??
              json['requiresExpiryDate'] ??
              false) ==
          true,
      requiresWarranty:
          (json['requires_warranty'] ?? json['requiresWarranty'] ?? false) ==
          true,
      defaultWarrantyMonths:
          (json['default_warranty_months'] ?? json['defaultWarrantyMonths'])
              is int
          ? (json['default_warranty_months'] ?? json['defaultWarrantyMonths'])
                as int
          : int.tryParse(
              (json['default_warranty_months'] ??
                      json['defaultWarrantyMonths'] ??
                      '')
                  .toString(),
            ),
      status: (json['status'] ?? 'active').toString(),
      defaultManufacturingDate: parseDate(
        metadata?['default_manufacturing_date']?.toString(),
      ),
      defaultExpiryDate: parseDate(
        metadata?['default_expiry_date']?.toString(),
      ),

      // Commercial pricing
      unitPrice: (json['unit_price'] ?? json['unitPrice'])?.toDouble(),
      cartonPrice: (json['carton_price'] ?? json['cartonPrice'])?.toDouble(),
      wholesalePrice: (json['wholesale_price'] ?? json['wholesalePrice'])
          ?.toDouble(),
      currency: (json['currency'] ?? 'NGN').toString(),
      discountType: json['discount_type'] ?? json['discountType']?.toString(),
      discountValue: (json['discount_value'] ?? json['discountValue'])
          ?.toDouble(),
      moq: (json['moq'] ?? json['minimum_order_quantity'] ?? 1) is int
          ? (json['moq'] ?? json['minimum_order_quantity'] ?? 1) as int
          : int.tryParse(
                  (json['moq'] ?? json['minimum_order_quantity'] ?? '1')
                      .toString(),
                ) ??
                1,
      marketplaceEnabled:
          (json['marketplace_enabled'] ??
              json['marketplaceEnabled'] ??
              false) ==
          true,
      bonusQuantity: (json['bonus_quantity'] ?? json['bonusQuantity']) is int
          ? (json['bonus_quantity'] ?? json['bonusQuantity']) as int
          : int.tryParse(
              (json['bonus_quantity'] ?? json['bonusQuantity'] ?? '')
                  .toString(),
            ),
      bonusThreshold: (json['bonus_threshold'] ?? json['bonusThreshold']) is int
          ? (json['bonus_threshold'] ?? json['bonusThreshold']) as int
          : int.tryParse(
              (json['bonus_threshold'] ?? json['bonusThreshold'] ?? '')
                  .toString(),
            ),
      walletCredit: (json['wallet_credit'] ?? json['walletCredit'])?.toDouble(),
      promoCode: json['promo_code'] ?? json['promoCode']?.toString(),
      promoDiscount: (json['promo_discount'] ?? json['promoDiscount'])
          ?.toDouble(),
      tags: parseTags(json['tags']),
      volumeDiscounts: parseVolumeDiscounts(
        json['volume_discounts'] ?? json['volumeDiscounts'],
      ),
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
          'default_manufacturing_date': defaultManufacturingDate!
              .toIso8601String()
              .split('T')
              .first,
        if (defaultExpiryDate != null)
          'default_expiry_date': defaultExpiryDate!
              .toIso8601String()
              .split('T')
              .first,
      },
      // Commercial pricing
      if (unitPrice != null) 'unit_price': unitPrice,
      if (cartonPrice != null) 'carton_price': cartonPrice,
      if (wholesalePrice != null) 'wholesale_price': wholesalePrice,
      'currency': currency,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      'moq': moq,
      'marketplace_enabled': marketplaceEnabled,
      if (bonusQuantity != null) 'bonus_quantity': bonusQuantity,
      if (bonusThreshold != null) 'bonus_threshold': bonusThreshold,
      if (walletCredit != null) 'wallet_credit': walletCredit,
      if (promoCode != null) 'promo_code': promoCode,
      if (promoDiscount != null) 'promo_discount': promoDiscount,
      if (tags != null) 'tags': tags,
      if (volumeDiscounts != null)
        'volume_discounts': volumeDiscounts!.map((t) => t.toJson()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    String? description,
    String? category,
    String? productType,
    bool? requiresManufacturingDate,
    bool? requiresExpiryDate,
    bool? requiresWarranty,
    int? defaultWarrantyMonths,
    String? status,
    DateTime? defaultManufacturingDate,
    DateTime? defaultExpiryDate,
    // Commercial pricing
    double? unitPrice,
    double? cartonPrice,
    double? wholesalePrice,
    String? currency,
    String? discountType,
    double? discountValue,
    int? moq,
    bool? marketplaceEnabled,
    int? bonusQuantity,
    int? bonusThreshold,
    double? walletCredit,
    String? promoCode,
    double? promoDiscount,
    List<String>? tags,
    List<VolumeDiscountTier>? volumeDiscounts,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      category: category ?? this.category,
      productType: productType ?? this.productType,
      requiresManufacturingDate:
          requiresManufacturingDate ?? this.requiresManufacturingDate,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      requiresWarranty: requiresWarranty ?? this.requiresWarranty,
      defaultWarrantyMonths:
          defaultWarrantyMonths ?? this.defaultWarrantyMonths,
      status: status ?? this.status,
      defaultManufacturingDate:
          defaultManufacturingDate ?? this.defaultManufacturingDate,
      defaultExpiryDate: defaultExpiryDate ?? this.defaultExpiryDate,
      // Commercial pricing
      unitPrice: unitPrice ?? this.unitPrice,
      cartonPrice: cartonPrice ?? this.cartonPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      currency: currency ?? this.currency,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      moq: moq ?? this.moq,
      marketplaceEnabled: marketplaceEnabled ?? this.marketplaceEnabled,
      bonusQuantity: bonusQuantity ?? this.bonusQuantity,
      bonusThreshold: bonusThreshold ?? this.bonusThreshold,
      walletCredit: walletCredit ?? this.walletCredit,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      tags: tags ?? this.tags,
      volumeDiscounts: volumeDiscounts ?? this.volumeDiscounts,
    );
  }
}

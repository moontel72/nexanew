/// Domain model for catering inventory items.
class CateringItem {
  final String id;
  final String companyId;
  final String? categoryId;
  final String? categoryName;
  final String name;
  final String? sku;
  final String unit;
  final int stockOnHand;
  final int lowStockThreshold;
  final int unitPricePaisa;
  final String? imageUrl;
  final String status; // active | discontinued

  const CateringItem({
    required this.id,
    required this.companyId,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.sku,
    this.unit = 'piece',
    this.stockOnHand = 0,
    this.lowStockThreshold = 10,
    this.unitPricePaisa = 0,
    this.imageUrl,
    this.status = 'active',
  });

  bool get isLowStock => stockOnHand <= lowStockThreshold;
  bool get isActive => status == 'active';

  double get unitPriceInMain => unitPricePaisa / 100.0;

  factory CateringItem.fromJson(Map<String, dynamic> json) {
    return CateringItem(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '',
      categoryId: json['category_id'],
      categoryName: json['category']?['name'],
      name: json['name'] ?? '',
      sku: json['sku'],
      unit: json['unit'] ?? 'piece',
      stockOnHand: (json['stock_on_hand'] ?? 0) is int
          ? json['stock_on_hand']
          : int.tryParse(json['stock_on_hand'].toString()) ?? 0,
      lowStockThreshold: (json['low_stock_threshold'] ?? 10) is int
          ? json['low_stock_threshold']
          : int.tryParse(json['low_stock_threshold'].toString()) ?? 10,
      unitPricePaisa: (json['unit_price_paisa'] ?? 0) is int
          ? json['unit_price_paisa']
          : int.tryParse(json['unit_price_paisa'].toString()) ?? 0,
      imageUrl: json['image_url'],
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'category_id': categoryId,
        'name': name,
        'sku': sku,
        'unit': unit,
        'stock_on_hand': stockOnHand,
        'low_stock_threshold': lowStockThreshold,
        'unit_price_paisa': unitPricePaisa,
        'image_url': imageUrl,
        'status': status,
      };
}

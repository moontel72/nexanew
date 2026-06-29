/// Domain model for a catering category.
class CateringCategory {
  final String id;
  final String companyId;
  final String name;
  final String? icon;
  final int sortOrder;
  final int itemCount;

  const CateringCategory({
    required this.id,
    required this.companyId,
    required this.name,
    this.icon,
    this.sortOrder = 0,
    this.itemCount = 0,
  });

  factory CateringCategory.fromJson(Map<String, dynamic> json) {
    return CateringCategory(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      sortOrder: (json['sort_order'] ?? 0) is int
          ? json['sort_order']
          : int.tryParse(json['sort_order'].toString()) ?? 0,
      itemCount: (json['items_count'] ?? 0) is int
          ? json['items_count']
          : int.tryParse(json['items_count'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'icon': icon,
        'sort_order': sortOrder,
      };
}

/// Domain model for a catering issuance (items given to a bus/trip).
class CateringIssuance {
  final String id;
  final String companyId;
  final String storekeeperId;
  final String? tripId;
  final String? routeId;
  final String? busRegNumber;
  final String? conductorName;
  final String status; // pending | issued | partially_returned | reconciled
  final String? notes;
  final DateTime? issuedAt;
  final DateTime? reconciledAt;
  final DateTime createdAt;
  final List<CateringIssuanceItem> items;

  const CateringIssuance({
    required this.id,
    required this.companyId,
    required this.storekeeperId,
    this.tripId,
    this.routeId,
    this.busRegNumber,
    this.conductorName,
    this.status = 'pending',
    this.notes,
    this.issuedAt,
    this.reconciledAt,
    required this.createdAt,
    this.items = const [],
  });

  bool get isPending => status == 'pending';
  bool get isIssued => status == 'issued';
  bool get isReconciled => status == 'reconciled';

  factory CateringIssuance.fromJson(Map<String, dynamic> json) {
    return CateringIssuance(
      id: json['id'] ?? '',
      companyId: json['company_id'] ?? '',
      storekeeperId: json['storekeeper_id'] ?? '',
      tripId: json['trip_id'],
      routeId: json['route_id'],
      busRegNumber: json['bus_reg_number'],
      conductorName: json['conductor_name'],
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      issuedAt: json['issued_at'] != null ? DateTime.tryParse(json['issued_at']) : null,
      reconciledAt: json['reconciled_at'] != null ? DateTime.tryParse(json['reconciled_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => CateringIssuanceItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

/// Domain model for a line item within an issuance.
class CateringIssuanceItem {
  final String id;
  final String issuanceId;
  final String itemId;
  final String? itemName;
  final String? itemUnit;
  final int quantityIssued;
  final int quantityReturned;
  final int quantitySold;
  final int quantityWasted;
  final int quantityStaff;
  final int quantityComplimentary;
  final int unitPricePaisa;

  const CateringIssuanceItem({
    required this.id,
    required this.issuanceId,
    required this.itemId,
    this.itemName,
    this.itemUnit,
    this.quantityIssued = 0,
    this.quantityReturned = 0,
    this.quantitySold = 0,
    this.quantityWasted = 0,
    this.quantityStaff = 0,
    this.quantityComplimentary = 0,
    this.unitPricePaisa = 0,
  });

  int get outstandingQuantity => (quantityIssued - quantityReturned - quantitySold - quantityWasted - quantityStaff - quantityComplimentary).clamp(0, 999999);

  factory CateringIssuanceItem.fromJson(Map<String, dynamic> json) {
    return CateringIssuanceItem(
      id: json['id'] ?? '',
      issuanceId: json['issuance_id'] ?? '',
      itemId: json['item_id'] ?? '',
      itemName: json['item']?['name'],
      itemUnit: json['item']?['unit'],
      quantityIssued: _parseInt(json['quantity_issued']),
      quantityReturned: _parseInt(json['quantity_returned']),
      quantitySold: _parseInt(json['quantity_sold']),
      quantityWasted: _parseInt(json['quantity_wasted']),
      quantityStaff: _parseInt(json['quantity_staff']),
      quantityComplimentary: _parseInt(json['quantity_complimentary']),
      unitPricePaisa: _parseInt(json['unit_price_paisa']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
